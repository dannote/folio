# Changelog

## 0.2.3 (2026-04-24)

### Fixes

- Remove musl target from precompiled NIFs — musl toolchain doesn't support cdylib builds for this crate

## 0.2.2 (2026-04-24)

### Fixes

- musl target: add `RUSTFLAGS=-C target-feature=-crt-static` to support cdylib builds

## 0.2.1 (2026-04-24)

### Fixes

- `rustler_precompiled` release workflow now fetches git submodules and builds without `cross`
- Added missing `vendor/typst` submodule checkout in CI

## 0.2.0 (2026-04-23)

### Content

- `grid/2` and `grid_cell/2` — CSS Grid-like layouts with `:columns`, `:rows`, `:gutter`, `:colspan`, `:rowspan`, `:align`, `:fill`
- `local_set/2` — local style overrides (`:hyphenate`, `:justify`, `:first_line_indent`) mirroring Typst's `#set` scoping
- `show/2` — Elixir-side show rules that transform content elements before compilation (custom enum/list formatting, etc.)
- `raw_typst/1` — escape hatch for injecting raw Typst markup when the DSL isn't enough

### Styles

- `lang/1` — document language for hyphenation (e.g. `"ru"`)
- `hyphenate/1` — enable/disable text hyphenation
- `leading/1` — line leading in em units
- `par_spacing/1` — paragraph spacing in em units
- `par_indent/2` — now supports `all: true` to indent all paragraphs including after headings/lists
- `enum_indent/1`, `enum_body_indent/1`, `enum_item_spacing/1` — enum list layout control
- `list_indent/1`, `list_body_indent/1`, `list_item_spacing/1` — bullet list layout control

### Engine

- System font loading via `fontdb` — `font_family(["Times New Roman"])` now works when the font is installed
- `em` unit parsing — `hspace("0.3em")`, `vspace("0.65em")` resolve correctly
- `fr` unit parsing — `grid(columns: ["1fr", "1fr"])` resolves correctly instead of falling back to 100%
- `Block` `above`/`below` fields now wired through to Typst block spacing
- Auto parbreak insertion fixed — no longer inserts spurious breaks between arbitrary block elements (grid, align, vspace, etc.)

## 0.1.0 (2026-04-15)

Initial release.

### Core

- `~MD` sigil: Markdown with `#{}` Elixir interpolation, `p`/`s` modifiers for PDF/SVG output
- `Folio.to_pdf/2`, `Folio.to_svg/2`, `Folio.to_png/2` — accept markdown, content nodes, or `Folio.Document`
- `Folio.parse_markdown/1` returns `{:ok, nodes} | {:error, ParseError}`, `parse_markdown!/1` raises
- Session-scoped file attachments via `Folio.Document.attach_file/3`
- Global file registry via `Folio.register_file/2` / `Folio.unregister_file/2`
- PNG export with configurable `dpi:` option (default 2.0)
- Typst layout engine via Rustler NIF — content trees built directly, no Typst source generation

### DSL (`use Folio`)

40+ builder functions: `text`, `heading`, `strong`, `emph`, `strike`, `underline`, `highlight`, `superscript`, `subscript`, `smallcaps`, `image`, `figure`, `table`, `columns`, `align`, `block`, `vspace`, `hspace`, `pagebreak`, `colbreak`, `pad`, `stack`, `rect`, `square`, `circle`, `ellipse`, `line`, `polygon`, `outline`, `blockquote`, `list`, `enum`, `term_list`, `footnote`, `cite`, `bibliography`, `divider`, `link`, `label`, `ref`, `math`, `raw`

### Styles

`Folio.Styles` functions for page size, margins, fonts, colors, page numbering, headers/footers, heading styling, paragraph indent, and text justification.

### Markdown support

GFM tables, strikethrough, autolinks, math (`$...$` / `$$...$$`), ordered/unordered lists, blockquotes, code blocks with language hints, images, and thematic breaks — all parsed via comrak.
