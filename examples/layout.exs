# Ported from typst/tests/suite/layout/{table,columns,spacing,stack}.typ
# and typst/tests/suite/model/{heading,figure,quote,list,enum,terms,outline}.typ
#
# Run: mix run examples/layout.exs

use Folio

File.mkdir_p!("examples/output")

# ── Headings (from heading.typ: heading-basic, heading-block) ────────────────

{:ok, pdf} = Folio.to_pdf([
  heading(1, "Level 1"),
  heading(2, "Level 2"),
  heading(3, "Level 3"),
  text("Normal paragraph between headings."),
  heading(1, "Another H1"),
  heading(2, "Another H2"),
  text("Content under H2."),
])
File.write!("examples/output/heading.pdf", pdf)
IO.puts("  heading.pdf — #{byte_size(pdf)} bytes")

# ── Columns (from columns.typ) ───────────────────────────────────────────────

# columns-in-fixed-size-rect: text flowing across columns
{:ok, pdf} = Folio.to_pdf([
  heading(1, "Columns"),
  text("Two-column layout with flowing text:"),
  vspace("8pt"),
  columns(2, do: [
    text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."),
    text("Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."),
    text("Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur."),
  ]),
  vspace("12pt"),
  text("Three-column layout:"),
  vspace("4pt"),
  columns(3, do: [
    rect(fill: "#E74C3C", width: "100%", height: "40pt"),
    rect(fill: "#3498DB", width: "100%", height: "40pt"),
    rect(fill: "#2ECC71", width: "100%", height: "40pt"),
  ]),
])
File.write!("examples/output/columns.pdf", pdf)
IO.puts("  columns.pdf — #{byte_size(pdf)} bytes")

# ── Tables (from table.typ: table-newlines, table-gutters) ───────────────────

# table with header and body
{:ok, pdf} = Folio.to_pdf([
  heading(1, "Tables"),
  text("Simple 3-column table:"),
  vspace("4pt"),
  table([gutter: "4pt"], do: [
    table_header([table_cell(strong("A")), table_cell(strong("B")), table_cell(strong("C"))]),
    table_row([table_cell("1"), table_cell("2"), table_cell("3")]),
    table_row([table_cell("4"), table_cell("5"), table_cell("6")]),
    table_row([table_cell("7"), table_cell("8"), table_cell("9")]),
  ]),
  vspace("12pt"),
  text("Table with gutter:"),
  vspace("4pt"),
  table([gutter: "8pt"], do: [
    table_header([table_cell(strong("Name")), table_cell(strong("Age")), table_cell(strong("City"))]),
    table_row([table_cell("Alice"), table_cell("30"), table_cell("NYC")]),
    table_row([table_cell("Bob"), table_cell("25"), table_cell("LA")]),
    table_row([table_cell("Charlie"), table_cell("35"), table_cell("Chicago")]),
  ]),
])
File.write!("examples/output/table.pdf", pdf)
IO.puts("  table.pdf — #{byte_size(pdf)} bytes")

# ── Lists (from list.typ: list-basic, list-nested) ───────────────────────────

{:ok, pdf} = ~MD"""
# Shopping List

- Apples
- Potatoes
- Juice
- Bread
- Milk
"""p
File.write!("examples/output/list.pdf", pdf)
IO.puts("  list.pdf — #{byte_size(pdf)} bytes")

# ── Enumerations (from enum.typ: enum-function-call) ─────────────────────────

{:ok, pdf} = ~MD"""
# Steps

1. First step
2. Second step
3. Third step
"""p
File.write!("examples/output/enum.pdf", pdf)
IO.puts("  enum.pdf — #{byte_size(pdf)} bytes")

# ── Blockquotes (from quote.typ: quote-dir-author-pos) ───────────────────────

{:ok, pdf} = Folio.to_pdf([
  heading(1, "Quotations"),
  text("Inline quote:"),
  blockquote([text("Cogito, ergo sum.")], attribution: "René Descartes"),
  vspace("8pt"),
  text("Another quote:"),
  blockquote([text("In a hole in the ground there lived a hobbit.")], attribution: "J.R.R. Tolkien"),
])
File.write!("examples/output/quote.pdf", pdf)
IO.puts("  quote.pdf — #{byte_size(pdf)} bytes")

# ── Figure (from figure.typ: figure-basic) ───────────────────────────────────

{:ok, pdf} = Folio.to_pdf([
  heading(1, "Figures"),
  text("A figure with a colored rectangle and caption:"),
  figure(rect(width: "200pt", height: "60pt", fill: "#3498DB"), caption: "The blue rectangle."),
  vspace("8pt"),
  text("A figure with a circle:"),
  figure(circle(fill: "#E74C3C", radius: "30pt"), caption: "The red circle."),
])
File.write!("examples/output/figure.pdf", pdf)
IO.puts("  figure.pdf — #{byte_size(pdf)} bytes")

# ── Outline (from outline.typ) ───────────────────────────────────────────────

{:ok, pdf} = Folio.to_pdf([
  outline(title: "Contents"),
  heading(1, "Introduction"),
  text("First section content."),
  heading(2, "Background"),
  text("Subsection content."),
  heading(1, "Methods"),
  text("Second section content."),
  heading(2, "Experimental Setup"),
  text("Setup details."),
  heading(2, "Results"),
  text("The results were conclusive."),
  heading(1, "Conclusion"),
  text("Final thoughts."),
])
File.write!("examples/output/outline.pdf", pdf)
IO.puts("  outline.pdf — #{byte_size(pdf)} bytes")

# ── Spacing (from spacing.typ: spacing-h-and-v) ──────────────────────────────

{:ok, pdf} = Folio.to_pdf([
  heading(1, "Spacing"),
  text("Normal text"),
  vspace("12pt"),
  text("After 12pt vertical space"),
  vspace("24pt"),
  text("After 24pt vertical space"),
  text("Inline"),
  hspace("20pt"),
  text("gap"),
  hspace("20pt"),
  text("of 20pt"),
])
File.write!("examples/output/spacing.pdf", pdf)
IO.puts("  spacing.pdf — #{byte_size(pdf)} bytes")

# ── Term List (from terms.typ) ───────────────────────────────────────────────

{:ok, pdf} = Folio.to_pdf([
  heading(1, "Glossary"),
  term_list([
    {"Algorithm", "A step-by-step procedure for solving a problem"},
    {"Complexity", "The amount of resources required by an algorithm"},
    {"Consensus", "Agreement among distributed processes on a single data value"},
    {"Latency", "The time delay between a request and the response"},
    {"Throughput", "The rate at which a system processes requests"},
  ]),
])
File.write!("examples/output/terms.pdf", pdf)
IO.puts("  terms.pdf — #{byte_size(pdf)} bytes")

# ── Math (port of Typst math rendering) ──────────────────────────────────────

{:ok, pdf} = Folio.to_pdf([
  heading(1, "Mathematics"),
  text("Inline math: $x^2 + y^2 = z^2$ and $E = m c^2$."),
  vspace("8pt"),
  text("Block equations:"),
  vspace("4pt"),
  text("$$integral_0^infinity e^(-x^2) dif x = sqrt(pi) / 2$$"),
  vspace("8pt"),
  text("$$a^2 + b^2 = c^2$$"),
  vspace("8pt"),
  text("$$sum_(i=0)^n i = n(n+1)/2$$"),
])
File.write!("examples/output/math.pdf", pdf)
IO.puts("  math.pdf — #{byte_size(pdf)} bytes")

# ── Code blocks ───────────────────────────────────────────────────────────────

{:ok, pdf} = ~MD"""
# Code Examples

```elixir
defmodule Hello do
  def world do
    IO.puts("Hello, World!")
  end
end
```

```rust
fn main() {
    println!("Hello from Rust!");
}
```

Inline code: `mix test` runs the tests.
"""p
File.write!("examples/output/code.pdf", pdf)
IO.puts("  code.pdf — #{byte_size(pdf)} bytes")

# ── Text Formatting ──────────────────────────────────────────────────────────

{:ok, pdf} = Folio.to_pdf([
  heading(1, "Text Formatting"),
  text("Normal text. "),
  strong("Bold text. "),
  emph("Italic text. "),
  strike("Strikethrough. "),
  underline("Underline. "),
  vspace("6pt"),
  text("Superscript: x"),
  superscript("2"),
  text(" and subscript: H"),
  subscript("2"),
  text("O."),
  vspace("6pt"),
  smallcaps("Smallcaps text."),
  vspace("6pt"),
  highlight("Highlighted text.", fill: "#FFF3CD"),
  vspace("4pt"),
  highlight("Critical highlight.", fill: "#F8D7DA"),
  vspace("4pt"),
  highlight("Success highlight.", fill: "#D4EDDA"),
])
File.write!("examples/output/formatting.pdf", pdf)
IO.puts("  formatting.pdf — #{byte_size(pdf)} bytes")

# ── Divider (from divider.typ) ───────────────────────────────────────────────

{:ok, pdf} = Folio.to_pdf([
  heading(1, "Dividers"),
  text("Section one."),
  divider(),
  text("Section two."),
  divider(),
  text("Section three."),
  divider(),
  text("Final section."),
])
File.write!("examples/output/divider.pdf", pdf)
IO.puts("  divider.pdf — #{byte_size(pdf)} bytes")

# ── Page Breaks ───────────────────────────────────────────────────────────────

{:ok, pdf} = Folio.to_pdf([
  heading(1, "Page 1"),
  text("Content on the first page."),
  pagebreak(),
  heading(1, "Page 2"),
  text("Content on the second page."),
  pagebreak(),
  heading(1, "Page 3"),
  text("Content on the third page."),
], styles: [
  page_numbering("1"),
])
File.write!("examples/output/pagebreak.pdf", pdf)
IO.puts("  pagebreak.pdf — #{byte_size(pdf)} bytes")

IO.puts("\nDone. See examples/output/")
