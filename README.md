# Folio

Print-quality PDF/SVG/PNG from Markdown + Elixir, powered by [Typst](https://typst.app)'s layout engine via Rustler NIF.

## Why Folio

### Data-Driven Documents at Runtime

Typst reads static files. Folio builds content trees from live Elixir data — Ecto queries, API responses, GenServer state. A Phoenix app generates PDFs from the same data it renders in HTML, with zero intermediate files:

```elixir
def invoice_pdf(order) do
  ~MD"""
  # Invoice #{order.number}

  #{table([gutter: "4pt"], do: [
    table_header([table_cell("Item"), table_cell("Qty"), table_cell("Price")]),
    for item <- order.line_items do
      table_row([table_cell(item.name), table_cell("#{item.quantity}"), table_cell(Money.to_string(item.price))])
    end
  ])}
  """p
end
```

In plain Typst you'd serialize data to JSON/YAML, write it to disk, reference it from `.typ` files, and shell out to the CLI. Folio skips all of that.

### Composable Document Fragments

DSL functions return plain structs — document pieces are first-class Elixir values. Build reusable components as regular functions, pattern-match on them, store them, pipe them:

```elixir
defmodule Reports.Components do
  use Folio

  def kpi_card(label, value, trend) do
    block([above: "12pt", below: "12pt"], do: [
      strong(label),
      parbreak(),
      text("#{value} (#{trend})"),
    ])
  end
end
```

Folio lets you use all of Elixir — GenServers, protocols, behaviours, macros, Hex packages — as your composition layer.

### No Typst Language, No Typst Parser, No Typst Evaluator

Folio constructs `typst::Content` trees directly in Rust and feeds them straight to the layout engine. It bypasses Typst's parser, AST, and evaluation VM entirely:

- **No template injection** — there's no string template to inject into
- **No syntax errors** — content is structurally valid by construction
- **Smaller attack surface** — the Typst evaluator (file I/O, package imports, plugin loading) is never invoked
- **Faster for programmatic documents** — skipping parse + eval stages

### Elixir-Native Concurrency for Batch Generation

With Typst CLI, generating 10,000 invoices means 10,000 process spawns. With Folio on dirty schedulers:

```elixir
orders
|> Task.async_stream(
  fn order -> Folio.to_pdf(build_invoice(order)) end,
  max_concurrency: System.schedulers_online()
)
|> Stream.each(fn {:ok, pdf} -> upload(pdf) end)
|> Stream.run()
```

Fonts and the Typst library are loaded once in a Rust `LazyLock<GlobalState>`. Each PDF compilation shares that cached state.

### The Sigil as a Hybrid Format

`~MD"""..."""p` is a polyglot literal — Markdown for prose, `#{}` interpolation for dynamic content, DSL functions for layout primitives, `$...$` for math, and a single modifier for output format:

```elixir
~MD"""
#{heading(1, report.title)}

Written on #{Date.to_string(Date.utc_today())}.

#{for section <- report.sections do
  figure(
    image(section.chart_path, width: "200pt"),
    caption: section.title,
  )
end}

The model predicts $R^2 = #{Float.round(report.r_squared, 3)}$.
"""p
```

No Typst equivalent exists — Typst's templating is powerful but doesn't embed in another language's string interpolation.

## Quick start

```elixir
use Folio

# Markdown → PDF
{:ok, pdf} = Folio.to_pdf("# Hello\n\n**Bold** and $x^2$ math.")

# ~MD sigil with p modifier → {:ok, binary}
{:ok, pdf} = ~MD"""
# Report

Some **bold** content with inline $E = m c^2$ math.

| Metric | Value |
|--------|-------|
| A      | 1     |
| B      | 2     |
"""p

# Content nodes → {:ok, binary}
{:ok, pdf} = Folio.to_pdf([
  heading(1, "Hello"),
  text("Normal "),
  strong("bold"),
  text(" and "),
  emph("italic"),
])
```

## Export formats

```elixir
{:ok, pdf} = Folio.to_pdf("# Hello")       # PDF binary
{:ok, svgs} = Folio.to_svg("# Hello")      # [String.t()] — one SVG per page
{:ok, pngs} = Folio.to_png("# Hello")      # [binary()] — one PNG per page
```

## Styles

```elixir
{:ok, pdf} = Folio.to_pdf("Hello", styles: [
  Folio.Styles.page_size(width: 595, height: 842),
  Folio.Styles.font_family(["Helvetica"]),
  Folio.Styles.font_size(12),
  Folio.Styles.text_color("#222222"),
  Folio.Styles.page_numbering("1"),
])
```

## Document pipeline

```elixir
doc =
  Folio.Document.new()
  |> Folio.Document.add_style(Folio.Styles.page_numbering("1"))
  |> Folio.Document.add_style(Folio.Styles.font_family(["Helvetica"]))
  |> Folio.Document.add_content("# Invoice\n\n...")
  |> Folio.Document.add_content(Folio.parse_markdown("Terms and conditions."))

{:ok, pdf} = Folio.to_pdf(doc)
```

## Images

Register file bytes before referencing them:

```elixir
Folio.register_file("chart.png", File.read!("chart.png"))

# From Markdown
{:ok, pdf} = Folio.to_pdf("![Chart](chart.png)")

# From DSL
{:ok, pdf} = Folio.to_pdf([image("chart.png", width: "200pt", fit: "contain")])
```

## DSL reference

`use Folio` imports all builder functions. Every function returns a `%Folio.Content.*{}` struct.

### Text

| Function | Example |
|----------|---------|
| `text/1` | `text("hello")` |
| `strong/1` | `strong("bold")` |
| `emph/1` | `emph("italic")` |
| `strike/1` | `strike("deleted")` |
| `underline/1` | `underline("underlined")` |
| `highlight/2` | `highlight("note", fill: "#FFD700")` |
| `superscript/1` | `superscript("2")` |
| `subscript/1` | `subscript("2")` |
| `smallcaps/1` | `smallcaps("Hello")` |
| `raw/2` | `raw("x = 1", lang: "elixir")` |
| `link/2` | `link("https://example.com", "click")` |

### Structure

| Function | Example |
|----------|---------|
| `heading/2` | `heading(1, "Title")` |
| `blockquote/2` | `blockquote([text("Wisdom")], attribution: "Author")` |
| `list/2` | `list(["Apples", "Oranges"])` |
| `enum/2` | `enum(["First", "Second"])` |
| `term_list/1` | `term_list([{"Term", "Definition"}])` |
| `footnote/1` | `footnote(text("A note"))` |
| `divider/0` | `divider()` |
| `outline/1` | `outline(title: "Contents")` |
| `title/1` | `title("Document Title")` |

### Layout

| Function | Example |
|----------|---------|
| `columns/3` | `columns(2, do: [text("Col 1"), text("Col 2")])` |
| `align/2` | `align("center", [text("Centered")])` |
| `block/2` | `block(width: "100%", do: [text("Full width")])` |
| `vspace/1` | `vspace("24pt")` |
| `hspace/1` | `hspace("20pt")` |
| `pagebreak/1` | `pagebreak(weak: true)` |
| `colbreak/1` | `colbreak()` |
| `parbreak/0` | `parbreak()` |
| `pad/2` | `pad([top: "10pt"], do: [text("Padded")])` |
| `stack/2` | `stack([dir: "ltr"], do: [rect(...), rect(...)])` |
| `hide/1` | `hide(text("Hidden"))` |
| `place/2` | `place(text("Absolute"), alignment: "center")` |

### Shapes

| Function | Example |
|----------|---------|
| `rect/1` | `rect(width: "100pt", height: "50pt", fill: "#3498DB")` |
| `square/1` | `square(fill: "red", width: "40pt")` |
| `circle/1` | `circle(fill: "blue", radius: "20pt")` |
| `ellipse/1` | `ellipse(fill: "green", width: "80pt", height: "40pt")` |
| `line/1` | `line()` |
| `polygon/2` | `polygon(["0pt,0pt", "100pt,0pt", "50pt,50pt"], fill: "red")` |

All shapes accept `body`, `stroke`, `inset`, `outset` via keyword list.

### Tables

```elixir
table([gutter: "8pt"], do: [
  table_header([table_cell(strong("Name")), table_cell(strong("Age"))]),
  table_row([table_cell("Alice"), table_cell("30")]),
  table_row([table_cell("Bob"), table_cell("25")]),
])
```

`table_cell/2` accepts `rowspan:`, `colspan:`, `align:` options.

### Figures

```elixir
figure(
  circle(fill: "red", radius: "20pt"),
  caption: "A red circle.",
  numbering: "1",
  placement: "bottom",
)
```

### Images

```elixir
image("photo.png", width: "200pt", height: "100pt", fit: "contain")
```

Fit options: `"cover"` (default), `"contain"`, `"stretch"`.

### Math

Uses Typst's math syntax inside `$...$`:

```elixir
# Inline via Markdown
Folio.to_pdf("The equation $E = m c^2$")

# Block via Markdown
Folio.to_pdf("$$integral_0^1 x dif x = 1/3$$")

# Via DSL
math("x^2 + 1", block: true)
```

## Value syntax

All size/color/position values are strings parsed in the Rust NIF:

- **Lengths**: `"10pt"`, `"2cm"`, `"5mm"`, `"1in"`
- **Percentages**: `"50%"`, `"100%"`
- **Colors**: `"#RGB"`, `"#RRGGBB"`, `"#RRGGBBAA"`, `"rgb(255,0,0)"`, or named colors (`"red"`, `"blue"`, `"black"`, `"white"`, etc.)

## How it works

1. Markdown is parsed with [comrak](https://github.com/kivikakk/comrak) into an AST
2. AST nodes are converted to Elixir structs (`%Folio.Content.*{}`)
3. Structs cross the NIF boundary and become Typst `Content` objects
4. Typst's layout engine produces frames
5. Frames are exported to PDF/SVG/PNG

No Typst source strings are ever generated — Content trees are built directly in Rust.

## Installation

```elixir
def deps do
  [
    {:folio, "~> 0.1.0", github: "dannote/folio"}
  ]
end
```

Requires Rust toolchain for NIF compilation.

## License

MIT — see [LICENSE.md](LICENSE.md)
