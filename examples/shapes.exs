# Ported from typst/tests/suite/visualize/{rect,circle,ellipse,square,line}.typ
#
# Run: mix run examples/shapes.exs

use Folio

File.mkdir_p!("examples/output")

# ── Rect (from rect.typ) ─────────────────────────────────────────────────────

# rect-customization: rectangles with fills and sizing
rect_default = rect(width: "100pt", height: "50pt")
rect_textbox = rect(fill: "#2ECC71", body: [text("Textbox")])
rect_styled = rect(width: "200pt", height: "15pt", fill: "#46B3C2")

# rect-fill-stroke: color variants
rect_row = columns(3, do: [
  rect(width: "60pt", height: "20pt", fill: "#D6CD67"),
  rect(width: "60pt", height: "20pt", fill: "#EDD466"),
  rect(width: "60pt", height: "20pt", fill: "#E3BE62"),
])

# Fill palette
rect_palette = columns(6, do: [
  rect(width: "30pt", height: "20pt", fill: "#E74C3C"),
  rect(width: "30pt", height: "20pt", fill: "#E67E22"),
  rect(width: "30pt", height: "20pt", fill: "#F1C40F"),
  rect(width: "30pt", height: "20pt", fill: "#2ECC71"),
  rect(width: "30pt", height: "20pt", fill: "#3498DB"),
  rect(width: "30pt", height: "20pt", fill: "#9B59B6"),
])

{:ok, pdf} = Folio.to_pdf([
  heading(1, "Rectangles"),
  text("Default:"),
  rect_default, vspace("8pt"),
  text("Fit to text:"),
  rect_textbox, vspace("8pt"),
  text("Fixed with fill:"),
  rect_styled, vspace("8pt"),
  heading(2, "Color Row"),
  rect_row, vspace("8pt"),
  heading(2, "Palette"),
  rect_palette,
])
File.write!("examples/output/rect.pdf", pdf)
IO.puts("  rect.pdf — #{byte_size(pdf)} bytes")

# ── Circle (from circle.typ) ─────────────────────────────────────────────────

# circle: default and filled
{:ok, pdf} = Folio.to_pdf([
  heading(1, "Circles"),
  text("Default (needs explicit size):"),
  circle(width: "40pt", height: "40pt"), vspace("8pt"),
  text("Filled with text:"),
  circle(fill: "#EB5278", radius: "30pt",
    body: align("center", [text("But, soft!")])), vspace("8pt"),
  text("Green circle:"),
  circle(fill: "#2ECC71", radius: "25pt",
    body: align("center", [text("Hello")])),
])
File.write!("examples/output/circle.pdf", pdf)
IO.puts("  circle.pdf — #{byte_size(pdf)} bytes")

# ── Ellipse (from ellipse.typ) ───────────────────────────────────────────────

# ellipse: default and filled
{:ok, pdf} = Folio.to_pdf([
  heading(1, "Ellipses"),
  text("Default:"),
  ellipse(width: "80pt", height: "40pt"), vspace("8pt"),
  text("Filled with content:"),
  ellipse(fill: "#2ECC71", width: "120pt", height: "60pt",
    body: align("center", [text("Inside an ellipse!")])),
])
File.write!("examples/output/ellipse.pdf", pdf)
IO.puts("  ellipse.pdf — #{byte_size(pdf)} bytes")

# ── Square (from square.typ) ─────────────────────────────────────────────────

# square: default, filled, auto-sized
{:ok, pdf} = Folio.to_pdf([
  heading(1, "Squares"),
  text("Default:"),
  square(width: "30pt"), vspace("8pt"),
  text("Filled with centered text:"),
  square(fill: "#3498DB", width: "60pt",
    body: align("center", [strong("Typst")])), vspace("8pt"),
  text("Auto-sized:"),
  square(fill: "#E74C3C", width: "80pt",
    body: [text("Auto sized text inside")]),
])
File.write!("examples/output/square.pdf", pdf)
IO.puts("  square.pdf — #{byte_size(pdf)} bytes")

# ── Line (from line.typ) ─────────────────────────────────────────────────────

{:ok, pdf} = Folio.to_pdf([
  heading(1, "Lines"),
  text("Default line:"),
  line(), vspace("8pt"),
  text("Between paragraphs:"),
  text("Paragraph one."),
  line(),
  text("Paragraph two."),
])
File.write!("examples/output/line.pdf", pdf)
IO.puts("  line.pdf — #{byte_size(pdf)} bytes")

# ── All shapes on one page ───────────────────────────────────────────────────

{:ok, pdf} = Folio.to_pdf([
  heading(1, "All Shapes"),
  columns(3, do: [
    rect(width: "60pt", height: "40pt", fill: "#3498DB"),
    circle(fill: "#E74C3C", radius: "20pt"),
    ellipse(fill: "#2ECC71", width: "80pt", height: "40pt"),
  ]),
  vspace("12pt"),
  columns(3, do: [
    square(fill: "#9B59B6", width: "40pt"),
    rect(width: "80pt", height: "3pt", fill: "#F39C12"),
    circle(fill: "#1ABC9C", radius: "15pt"),
  ]),
  vspace("12pt"),
  line(),
], styles: [
  Folio.Styles.page_size(width: 595, height: 842),
  Folio.Styles.font_size(11),
])
File.write!("examples/output/all_shapes.pdf", pdf)
IO.puts("  all_shapes.pdf — #{byte_size(pdf)} bytes")

IO.puts("\nDone. See examples/output/")
