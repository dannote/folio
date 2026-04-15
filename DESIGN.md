# Typstex — Design

## What

Elixir bindings for Typst typesetting. Write documents in Markdown + Elixir DSL,
get print-quality PDF/SVG/PNG via Typst's layout engine. No Typst language.

## The Format

```elixir
use Folio

~MD"""
# #{report.title}

#{report.introduction}

## Key Findings

#{table columns: [auto, 1 |> fr, auto] do
  table_header ["Metric", "Value", "Trend"]
  for f <- report.findings do
    table_row [f.metric, f.value, f.trend]
  end
end}

#{if report.has_chart do
  figure do
    image report.chart_path, width: 70 |> pct
    caption report.chart_description
  end
end}

Growth follows $x^2 + 1$ distribution.

#{pagebreak()}

## Appendix
#{columns 2 do
  report.appendix_text
end}
"""p
```

`~MD"""..."""p` — Markdown with `#{}` Elixir interpolation, `p` modifier outputs PDF.

## Architecture

```
     Elixir                                     Rust (NIF)
     ───────                                     ──────────

~MD"""..."""p  ─parse─→  [Markdown chunks]      comrak parse
                         [DSL structs    ]  ──→  MDEx AST nodes
                                                + ExContent structs
                                                      │
                                                      ▼
                                              ex_to_content()
                                              per-node conversion
                                                      │
                                                      ▼
                                              typst Content tree
                                                      │
                                              layout_document()
                                                      │
                                              typst_pdf::pdf()
                                                      │
                                                      ▼
                                                 PDF bytes
```

Three inputs flow into the Rust NIF:

1. **Markdown text** — parsed by comrak, each `NodeValue` maps to a `Content` node
2. **DSL structs** — Elixir `%Folio.Content.*{}` → Rust `ExContent` → Typst `Content`
3. **Style rules** — `%Folio.Styles.*{}` → Rust `ExStyleRule` → Typst `Styles`

No Typst source string is ever generated. The Typst parser and evaluator are never invoked.
Content trees are built directly and fed to the layout engine.

## Elixir API

```elixir
Typstex.to_pdf!(source, assigns)   # → binary()
Typstex.to_svg!(source, assigns)   # → [binary()]
Typstex.to_png!(source, assigns)   # → [binary()]
```

Where `source` is either a Markdown string, `~MD` sigil, or `%Folio.Document{}`.

## DSL Functions

All return `%Folio.Content.*{}` structs:

- `heading(level, content)` — section heading
- `text(str)` — plain text
- `strong(content)` / `emph(content)` — bold / italic
- `image(src, opts)` — image
- `figure do ... end` — figure with caption
- `table opts do ... end` — table with rows/headers/cells
- `table_header(cells)` / `table_row(cells)` / `table_cell(content, opts)`
- `columns count do ... end` — multi-column layout
- `align(alignment, content)` — alignment
- `block opts do ... end` — block container
- `pad opts do ... end` — padding
- `pagebreak()` / `parbreak()` / `linebreak()`
- `list(items)` / `enum(items)` — lists
- `link(url, text)` — hyperlink
- `math(content, opts)` — math expression
- `raw(text, opts)` — code block
- `bibliography(source, opts)` — bibliography
- `label(name)` / `ref(target)` — labels and references

## Style Rules

Applied via `Folio.Document` or `doc` macro:

```elixir
Folio.Document.configure(page: [paper: :a4, margin: 2 |> cm], font: "Helvetica")
|> Folio.Document.add_styles([
  Styles.show_set({:heading, level: 1}, :text, size: pt(17)),
  Styles.show_set({:heading, level: 1}, :align, alignment: :center),
])
```

## Files

```
folio/
├── lib/
│   ├── folio.ex              # API + use macro
│   ├── folio/
│   │   ├── sigil.ex            # ~MD sigil
│   │   ├── content.ex          # Content node structs (30+ element types)
│   │   ├── document.ex         # Document struct (content + styles)
│   │   ├── dsl.ex              # Builder functions (heading, figure, table...)
│   │   ├── styles.ex           # SetRule, ShowSetRule, ShowRule structs
│   │   └── values.ex           # Unit types (pt, cm, mm, em, fr, pct)
├── native/
│   └── folio_nif/
│       ├── Cargo.toml
│       └── src/
│           ├── lib.rs           # NIF: compile(), parse_markdown()
│           ├── types.rs         # ExContent, ExValue, ExStyleRule (NifStruct)
│           ├── convert.rs       # ExContent → typst Content
│           ├── mdex_bridge.rs   # comrak NodeValue → ExContent → typst Content
│           ├── styles.rs        # ExStyleRule → typst Styles
│           ├── math.rs          # Math string → Typst math Content
│           └── world.rs         # World impl (fonts via typst-assets)
└── test/
```

## Key Design Decisions

1. **No Typst source strings** — Content trees built directly in Rust
2. **comrak for Markdown** — same parser as MDEx, proven and fast
3. **Rustler NifStruct** — Elixir structs map 1:1 to Rust types across NIF
4. **DSL functions return structs** — not strings, not AST — plain data
5. **Math is parsed by Typst** — math strings go through `typst_syntax::parse_math()`
6. **Style rules as data** — not macros, not code — plain keyword lists/maps
