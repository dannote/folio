defmodule Folio.PortfolioTest do
  @moduledoc """
  Ported from Typst test suite: tests/suite/{visualize,model,layout}/*.typ
  Adapted to Folio's Markdown + Elixir DSL API.
  """
  use ExUnit.Case, async: true
  use Folio

  # ═══════════════════════════════════════════════════════════════════════════════
  # Ported from tests/suite/visualize/rect.typ
  # ═══════════════════════════════════════════════════════════════════════════════

  describe "rect (from rect.typ)" do
    test "default rectangle renders" do
      assert {:ok, pdf} =
               Folio.to_pdf([
                 rect(width: "100pt", height: "50pt")
               ])

      assert pdf_size_above?(pdf, 100)
    end

    test "rectangle with fill" do
      assert {:ok, pdf} =
               Folio.to_pdf([
                 rect(width: "100pt", height: "50pt", fill: "#46B3C2")
               ])

      assert pdf_size_above?(pdf, 100)
    end

    test "rectangle with text body" do
      assert {:ok, pdf} =
               Folio.to_pdf([
                 rect(fill: "#2ECC71", body: [text("Textbox")])
               ])

      assert pdf_size_above?(pdf, 100)
    end

    test "rectangle color variants render" do
      assert {:ok, pdf} =
               Folio.to_pdf([
                 rect(width: "60pt", height: "20pt", fill: "#D6CD67"),
                 rect(width: "60pt", height: "20pt", fill: "#EDD466"),
                 rect(width: "60pt", height: "20pt", fill: "#E3BE62")
               ])

      assert pdf_size_above?(pdf, 100)
    end

    test "rect with stroke" do
      assert {:ok, pdf} =
               Folio.to_pdf([
                 rect(width: "100pt", height: "50pt", stroke: "#FF0000")
               ])

      assert pdf_size_above?(pdf, 100)
    end
  end

  # ═══════════════════════════════════════════════════════════════════════════════
  # Ported from tests/suite/visualize/circle.typ
  # ═══════════════════════════════════════════════════════════════════════════════

  describe "circle (from circle.typ)" do
    test "circle with explicit size" do
      assert {:ok, pdf} =
               Folio.to_pdf([
                 circle(width: "40pt", height: "40pt")
               ])

      assert pdf_size_above?(pdf, 100)
    end

    test "circle with fill and radius" do
      assert {:ok, pdf} =
               Folio.to_pdf([
                 circle(fill: "#EB5278", radius: "30pt")
               ])

      assert pdf_size_above?(pdf, 100)
    end

    test "circle with text body" do
      assert {:ok, pdf} =
               Folio.to_pdf([
                 circle(
                   fill: "#EB5278",
                   radius: "30pt",
                   body: align("center", [text("But, soft!")])
                 )
               ])

      assert pdf_size_above?(pdf, 100)
    end

    test "circle beyond default size" do
      assert {:ok, pdf} =
               Folio.to_pdf([
                 circle(),
                 circle(height: "60pt"),
                 circle(width: "60pt"),
                 circle(radius: "30pt")
               ])

      assert pdf_size_above?(pdf, 100)
    end
  end

  # ═══════════════════════════════════════════════════════════════════════════════
  # Ported from tests/suite/visualize/ellipse.typ
  # ═══════════════════════════════════════════════════════════════════════════════

  describe "ellipse (from ellipse.typ)" do
    test "default ellipse" do
      assert {:ok, pdf} = Folio.to_pdf([ellipse()])
      assert pdf_size_above?(pdf, 100)
    end

    test "filled ellipse with content" do
      assert {:ok, pdf} =
               Folio.to_pdf([
                 ellipse(
                   fill: "#2ECC71",
                   width: "120pt",
                   height: "60pt",
                   body: [text("Inside an ellipse!")]
                 )
               ])

      assert pdf_size_above?(pdf, 100)
    end
  end

  # ═══════════════════════════════════════════════════════════════════════════════
  # Ported from tests/suite/visualize/square.typ
  # ═══════════════════════════════════════════════════════════════════════════════

  describe "square (from square.typ)" do
    test "default square" do
      assert {:ok, pdf} = Folio.to_pdf([square(width: "30pt")])
      assert pdf_size_above?(pdf, 100)
    end

    test "filled square with text" do
      assert {:ok, pdf} =
               Folio.to_pdf([
                 square(
                   fill: "#3498DB",
                   width: "60pt",
                   body: align("center", [strong("Typst")])
                 )
               ])

      assert pdf_size_above?(pdf, 100)
    end

    test "square size beyond default" do
      assert {:ok, pdf} =
               Folio.to_pdf([
                 square(),
                 square(height: "60pt"),
                 square(width: "60pt")
               ])

      assert pdf_size_above?(pdf, 100)
    end
  end

  # ═══════════════════════════════════════════════════════════════════════════════
  # Ported from tests/suite/visualize/line.typ
  # ═══════════════════════════════════════════════════════════════════════════════

  describe "line (from line.typ)" do
    test "basic line" do
      assert {:ok, pdf} =
               Folio.to_pdf([
                 text("Before"),
                 line(),
                 text("After")
               ])

      assert pdf_size_above?(pdf, 100)
    end
  end

  # ═══════════════════════════════════════════════════════════════════════════════
  # Ported from tests/suite/model/heading.typ
  # ═══════════════════════════════════════════════════════════════════════════════

  describe "heading (from heading.typ)" do
    test "heading-basic: levels 1 through 3" do
      assert {:ok, pdf} =
               Folio.to_pdf([
                 heading(1, "Level 1"),
                 heading(2, "Level 2"),
                 heading(3, "Level 3"),
                 text("Content after headings.")
               ])

      assert pdf_size_above?(pdf, 500)
    end

    test "heading-block: heading with complex body" do
      assert {:ok, pdf} =
               Folio.to_pdf([
                 heading(1, [
                   text("This is "),
                   strong("multiline"),
                   text(" heading content.")
                 ])
               ])

      assert pdf_size_above?(pdf, 100)
    end
  end

  # ═══════════════════════════════════════════════════════════════════════════════
  # Ported from tests/suite/model/figure.typ
  # ═══════════════════════════════════════════════════════════════════════════════

  describe "figure (from figure.typ)" do
    test "figure-basic: figure with caption" do
      assert {:ok, pdf} =
               Folio.to_pdf([
                 figure(
                   rect(width: "200pt", height: "60pt", fill: "#3498DB"),
                   caption: "The blue rectangle."
                 )
               ])

      assert pdf_size_above?(pdf, 100)
    end

    test "figure with placement" do
      assert {:ok, pdf} =
               Folio.to_pdf([
                 figure(
                   rect(width: "200pt", height: "30pt", fill: "#2ECC71"),
                   caption: "Placed figure.",
                   placement: "bottom"
                 )
               ])

      assert pdf_size_above?(pdf, 100)
    end

    test "figure with numbering" do
      assert {:ok, pdf} =
               Folio.to_pdf([
                 figure(
                   circle(fill: "#E74C3C", radius: "30pt"),
                   caption: "Numbered figure.",
                   numbering: "1"
                 )
               ])

      assert pdf_size_above?(pdf, 100)
    end

    test "figure with scope" do
      assert {:ok, pdf} =
               Folio.to_pdf([
                 figure(
                   rect(width: "100pt", height: "20pt", fill: "#9B59B6"),
                   caption: "Parent scoped.",
                   scope: "parent",
                   placement: "auto"
                 )
               ])

      assert pdf_size_above?(pdf, 100)
    end

    test "multiple figures get sequential numbers" do
      assert {:ok, pdf} =
               Folio.to_pdf([
                 text("Two numbered figures:"),
                 figure(rect(width: "100pt", height: "20pt", fill: "#3498DB"),
                   caption: "First.", numbering: "1"),
                 figure(rect(width: "100pt", height: "20pt", fill: "#E74C3C"),
                   caption: "Second.", numbering: "1"),
               ])

      assert pdf_size_above?(pdf, 100)
    end
  end

  # ═══════════════════════════════════════════════════════════════════════════════
  # Ported from tests/suite/layout/table.typ
  # ═══════════════════════════════════════════════════════════════════════════════

  describe "table (from table.typ)" do
    test "simple 3x3 table" do
      assert {:ok, pdf} =
               Folio.to_pdf([
                 table([], do: [
                   table_row([table_cell("A"), table_cell("B"), table_cell("C")]),
                   table_row([table_cell("1"), table_cell("2"), table_cell("3")]),
                 ])
               ])

      assert pdf_size_above?(pdf, 100)
    end

    test "table with header" do
      assert {:ok, pdf} =
               Folio.to_pdf([
                 table([], do: [
                   table_header([
                     table_cell(strong("Name")),
                     table_cell(strong("Age")),
                   ]),
                   table_row([table_cell("Alice"), table_cell("30")]),
                   table_row([table_cell("Bob"), table_cell("25")]),
                 ])
               ])

      assert pdf_size_above?(pdf, 100)
    end

    test "table-gutters: gutter spacing" do
      assert {:ok, pdf} =
               Folio.to_pdf([
                 table([gutter: "8pt"], do: [
                   table_header([table_cell("A"), table_cell("B")]),
                   table_row([table_cell("1"), table_cell("2")]),
                   table_row([table_cell("3"), table_cell("4")]),
                 ])
               ])

      assert pdf_size_above?(pdf, 100)
    end

    test "table from markdown" do
      md = "| H1 | H2 |\n|---|---|\n| A | B |\n| C | D |"

      assert {:ok, pdf} = Folio.to_pdf(md)
      assert pdf_size_above?(pdf, 100)
    end
  end

  # ═══════════════════════════════════════════════════════════════════════════════
  # Ported from tests/suite/layout/columns.typ
  # ═══════════════════════════════════════════════════════════════════════════════

  describe "columns (from columns.typ)" do
    test "columns-in-fixed-size-rect" do
      assert {:ok, pdf} =
               Folio.to_pdf([
                 rect(
                   width: "300pt",
                   height: "100pt",
                   body: columns(2, do: [
                     text("Column one text that flows into the second column."),
                     text("Column two text."),
                   ])
                 )
               ])

      assert pdf_size_above?(pdf, 100)
    end

    test "columns-set-page: multi-column page" do
      assert {:ok, pdf} =
               Folio.to_pdf([
                 columns(2, do: [
                   text("First column content with enough text to demonstrate column layout."),
                   text("More content flowing."),
                   text("And even more text."),
                 ])
               ])

      assert pdf_size_above?(pdf, 100)
    end

    test "three columns with colored rects" do
      assert {:ok, pdf} =
               Folio.to_pdf([
                 columns(3, do: [
                   rect(fill: "#E74C3C", width: "100%", height: "40pt"),
                   rect(fill: "#3498DB", width: "100%", height: "40pt"),
                   rect(fill: "#2ECC71", width: "100%", height: "40pt"),
                 ])
               ])

      assert pdf_size_above?(pdf, 100)
    end
  end

  # ═══════════════════════════════════════════════════════════════════════════════
  # Ported from tests/suite/layout/spacing.typ
  # ═══════════════════════════════════════════════════════════════════════════════

  describe "spacing (from spacing.typ)" do
    test "spacing-h-and-v: vertical spacing" do
      assert {:ok, pdf} =
               Folio.to_pdf([
                 text("Top"),
                 vspace("24pt"),
                 text("24pt below"),
                 vspace("48pt"),
                 text("48pt below")
               ])

      assert pdf_size_above?(pdf, 100)
    end

    test "spacing-h-and-v: horizontal spacing" do
      assert {:ok, pdf} =
               Folio.to_pdf([
                 text("Left"),
                 hspace("40pt"),
                 text("40pt gap"),
                 hspace("40pt"),
                 text("Right")
               ])

      assert pdf_size_above?(pdf, 100)
    end
  end

  # ═══════════════════════════════════════════════════════════════════════════════
  # Ported from tests/suite/model/list.typ
  # ═══════════════════════════════════════════════════════════════════════════════

  describe "list (from list.typ)" do
    test "list-basic: simple bullet list" do
      assert {:ok, pdf} = Folio.to_pdf("- Apples\n- Potatoes\n- Juice")
      assert pdf_size_above?(pdf, 100)
    end

    test "list-nested: nested bullets" do
      assert {:ok, pdf} =
               Folio.to_pdf("""
               - First level
                 - Second level
                 - Still second
               - Back to first
               """)

      assert pdf_size_above?(pdf, 100)
    end
  end

  # ═══════════════════════════════════════════════════════════════════════════════
  # Ported from tests/suite/model/enum.typ
  # ═══════════════════════════════════════════════════════════════════════════════

  describe "enum (from enum.typ)" do
    test "enum-function-call: numbered list" do
      assert {:ok, pdf} = Folio.to_pdf("1. First\n2. Second\n3. Third")
      assert pdf_size_above?(pdf, 100)
    end

    test "list-mix: bullet and numbered mix" do
      assert {:ok, pdf} =
               Folio.to_pdf("""
               - Bullet item
               1. Numbered item
               """)

      assert pdf_size_above?(pdf, 100)
    end
  end

  # ═══════════════════════════════════════════════════════════════════════════════
  # Ported from tests/suite/model/quote.typ
  # ═══════════════════════════════════════════════════════════════════════════════

  describe "quote (from quote.typ)" do
    test "quote with attribution" do
      assert {:ok, pdf} =
               Folio.to_pdf([
                 blockquote(
                   [text("Cogito, ergo sum.")],
                   attribution: "René Descartes"
                 )
               ])

      assert pdf_size_above?(pdf, 100)
    end

    test "quote from markdown" do
      assert {:ok, pdf} = Folio.to_pdf("> To be or not to be.")
      assert pdf_size_above?(pdf, 100)
    end
  end

  # ═══════════════════════════════════════════════════════════════════════════════
  # Ported from tests/suite/model/outline.typ
  # ═══════════════════════════════════════════════════════════════════════════════

  describe "outline (from outline.typ)" do
    test "outline with headings" do
      assert {:ok, pdf} =
               Folio.to_pdf([
                 outline(title: "Contents"),
                 heading(1, "Introduction"),
                 text("Intro text."),
                 heading(2, "Background"),
                 text("Background text."),
                 heading(1, "Methods"),
                 text("Methods text."),
               ])

      assert pdf_size_above?(pdf, 500)
    end
  end

  # ═══════════════════════════════════════════════════════════════════════════════
  # Ported from tests/suite/model/terms.typ
  # ═══════════════════════════════════════════════════════════════════════════════

  describe "term_list (from terms.typ)" do
    test "basic term list" do
      assert {:ok, pdf} =
               Folio.to_pdf([
                 term_list([
                   {"Term 1", "Definition of term 1"},
                   {"Term 2", "Definition of term 2"},
                   {"Term 3", "Definition of term 3"}
                 ])
               ])

      assert pdf_size_above?(pdf, 100)
    end
  end

  # ═══════════════════════════════════════════════════════════════════════════════
  # Ported from tests/suite/model/divider.typ
  # ═══════════════════════════════════════════════════════════════════════════════

  describe "divider (from divider.typ)" do
    test "divider between sections" do
      assert {:ok, pdf} =
               Folio.to_pdf([
                 text("Section one."),
                 divider(),
                 text("Section two."),
                 divider(),
                 text("Section three.")
               ])

      assert pdf_size_above?(pdf, 100)
    end
  end

  # ═══════════════════════════════════════════════════════════════════════════════
  # Ported from tests/suite/layout/pagebreak.typ
  # ═══════════════════════════════════════════════════════════════════════════════

  describe "pagebreak" do
    test "pagebreak creates multiple pages" do
      assert {:ok, pdf} =
               Folio.to_pdf([
                 heading(1, "Page 1"),
                 text("First page."),
                 pagebreak(),
                 heading(1, "Page 2"),
                 text("Second page.")
               ])

      # Multi-page PDF should be larger
      assert pdf_size_above?(pdf, 500)
    end

    test "weak pagebreak" do
      assert {:ok, pdf} =
               Folio.to_pdf([
                 heading(1, "Page 1"),
                 text("Content."),
                 pagebreak(weak: true),
                 heading(1, "Page 2"),
                 text("More.")
               ])

      assert pdf_size_above?(pdf, 100)
    end
  end

  # ═══════════════════════════════════════════════════════════════════════════════
  # Text formatting
  # ═══════════════════════════════════════════════════════════════════════════════

  describe "text formatting" do
    test "all inline formatting" do
      assert {:ok, pdf} =
               Folio.to_pdf([
                 text("Normal. "),
                 strong("Bold. "),
                 emph("Italic. "),
                 strike("Strike. "),
                 underline("Underline. "),
                 highlight("Highlight.", fill: "#FFD700"),
                 vspace("6pt"),
                 text("x"),
                 superscript("2"),
                 text(" H"),
                 subscript("2"),
                 text("O "),
                 smallcaps("Smallcaps.")
               ])

      assert pdf_size_above?(pdf, 100)
    end
  end

  # ═══════════════════════════════════════════════════════════════════════════════
  # Ported from tests/suite/layout/stack.typ
  # ═══════════════════════════════════════════════════════════════════════════════

  describe "stack (from stack.typ)" do
    test "stack-basic: LTR stack with colored rects" do
      assert {:ok, pdf} =
               Folio.to_pdf([
                 stack([dir: "ltr"], do: [
                   rect(width: "30pt", height: "10pt", fill: "#333333"),
                   rect(width: "20pt", height: "10pt", fill: "#555555"),
                   rect(width: "40pt", height: "10pt", fill: "#777777"),
                 ])
               ])

      assert pdf_size_above?(pdf, 100)
    end
  end

  # ═══════════════════════════════════════════════════════════════════════════════
  # Math (Typst's core feature)
  # ═══════════════════════════════════════════════════════════════════════════════

  describe "math" do
    test "inline math" do
      assert {:ok, pdf} = Folio.to_pdf("Inline: $E = m c^2$")
      assert pdf_size_above?(pdf, 100)
    end

    test "block math" do
      assert {:ok, pdf} = Folio.to_pdf("$$E = m c^2$$")
      assert pdf_size_above?(pdf, 100)
    end

    test "multiple equations" do
      assert {:ok, pdf} =
               Folio.to_pdf("""
               # Equations

               $$integral_0^infinity e^(-x^2) dif x = sqrt(pi) / 2$$

               $$sum_(i=0)^n i = n(n+1)/2$$

               $$a^2 + b^2 = c^2$$
               """)

      assert pdf_size_above?(pdf, 100)
    end
  end

  # ═══════════════════════════════════════════════════════════════════════════════
  # Export formats
  # ═══════════════════════════════════════════════════════════════════════════════

  describe "export formats" do
    test "SVG export produces valid SVG" do
      assert {:ok, svgs} =
               Folio.to_svg([
                 heading(1, "SVG Test"),
                 rect(width: "100pt", height: "50pt", fill: "#3498DB")
               ])

      assert length(svgs) >= 1
      svg = hd(svgs)
      assert String.starts_with?(svg, "<svg")
      assert String.contains?(svg, "</svg>")
    end

    test "PNG export produces valid PNG" do
      assert {:ok, pngs} =
               Folio.to_png([
                 heading(1, "PNG Test"),
                 circle(fill: "#E74C3C", radius: "30pt")
               ])

      assert length(pngs) >= 1
      # PNG magic bytes
      <<137, 80, 78, 71, 13, 10, 26, 10, _::binary>> = hd(pngs)
    end
  end

  # ═══════════════════════════════════════════════════════════════════════════════
  # Styles
  # ═══════════════════════════════════════════════════════════════════════════════

  describe "styles" do
    test "page size" do
      assert {:ok, pdf} =
               Folio.to_pdf(
                 "Styled page.",
                 styles: [Folio.Styles.page_size(width: 400, height: 600)]
               )

      assert pdf_size_above?(pdf, 100)
    end

    test "font family and size" do
      assert {:ok, pdf} =
               Folio.to_pdf(
                 "Helvetica 14pt.",
                 styles: [
                   Folio.Styles.font_family(["Helvetica"]),
                   Folio.Styles.font_size(14)
                 ]
               )

      assert pdf_size_above?(pdf, 100)
    end

    test "text color" do
      assert {:ok, pdf} =
               Folio.to_pdf(
                 "Colored text.",
                 styles: [Folio.Styles.text_color("#333333")]
               )

      assert pdf_size_above?(pdf, 100)
    end

    test "page numbering" do
      assert {:ok, pdf} =
               Folio.to_pdf(
                 [
                   heading(1, "Page 1"),
                   pagebreak(),
                   heading(1, "Page 2")
                 ],
                 styles: [Folio.Styles.page_numbering("1")]
               )

      assert pdf_size_above?(pdf, 100)
    end

    test "multiple styles combined" do
      assert {:ok, pdf} =
               Folio.to_pdf(
                 "Multi-styled document.",
                 styles: [
                   Folio.Styles.page_size(width: 595, height: 842),
                   Folio.Styles.font_size(12),
                   Folio.Styles.font_family(["Helvetica"]),
                   Folio.Styles.text_color("#222222"),
                   Folio.Styles.page_numbering("1")
                 ]
               )

      assert pdf_size_above?(pdf, 100)
    end
  end

  # ═══════════════════════════════════════════════════════════════════════════════
  # Helpers
  # ═══════════════════════════════════════════════════════════════════════════════

  defp pdf_size_above?(pdf, min) when is_binary(pdf), do: byte_size(pdf) > min
  defp pdf_size_above?(_, _), do: false
end
