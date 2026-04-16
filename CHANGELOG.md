# Changelog

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
