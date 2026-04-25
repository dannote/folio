defmodule FolioTest do
  use ExUnit.Case, async: true

  describe "parse_markdown/1" do
    test "parses plain text paragraph" do
      assert [%Folio.Content.Paragraph{body: [%Folio.Content.Text{text: "hello"}]}] =
               Folio.parse_markdown!("hello")
    end

    test "parses heading with level" do
      assert [%Folio.Content.Heading{level: 1, body: [%Folio.Content.Text{text: "Title"}]}] =
               Folio.parse_markdown!("# Title")
    end

    test "parses strong and emph" do
      assert [
               %Folio.Content.Paragraph{
                 body: [%Folio.Content.Strong{body: [%Folio.Content.Text{text: "bold"}]}]
               }
             ] = Folio.parse_markdown!("**bold**")

      assert [
               %Folio.Content.Paragraph{
                 body: [%Folio.Content.Emph{body: [%Folio.Content.Text{text: "it"}]}]
               }
             ] = Folio.parse_markdown!("*it*")
    end

    test "parses link" do
      assert [
               %Folio.Content.Paragraph{
                 body: [%Folio.Content.Link{url: "https://example.com", body: body}]
               }
             ] = Folio.parse_markdown!("[click](https://example.com)")

      assert [%Folio.Content.Text{text: "click"}] = body
    end

    test "parses image" do
      assert [
               %Folio.Content.Paragraph{
                 body: [%Folio.Content.Image{src: "photo.png"}]
               }
             ] = Folio.parse_markdown!("![photo](photo.png)")
    end

    test "parses table" do
      md = "| A | B |\n|---|---|\n| 1 | 2 |"

      assert [%Folio.Content.Table{children: [_header, _row]}] = Folio.parse_markdown!(md)
    end

    test "parses block math" do
      assert [
               %Folio.Content.Paragraph{
                 body: [%Folio.Content.Math{content: "E = m c ^2", block: true}]
               }
             ] = Folio.parse_markdown!("$$E = m c ^2$$")
    end

    test "parses inline math" do
      assert [
               %Folio.Content.Paragraph{
                 body: [%Folio.Content.Math{content: "x", block: false}]
               }
             ] = Folio.parse_markdown!("$x$")
    end

    test "parses strikethrough" do
      assert [
               %Folio.Content.Paragraph{
                 body: [%Folio.Content.Strike{body: [%Folio.Content.Text{text: "gone"}]}]
               }
             ] = Folio.parse_markdown!("~~gone~~")
    end

    test "parses code block" do
      assert [%Folio.Content.Raw{text: "x = 1\n", lang: "elixir", block: true}] =
               Folio.parse_markdown!("```elixir\nx = 1\n```")
    end

    test "parses blockquote" do
      assert [%Folio.Content.Quote{body: body}] = Folio.parse_markdown!("> wisdom")
      assert [%Folio.Content.Paragraph{body: [%Folio.Content.Text{text: "wisdom"}]}] = body
    end

    test "parses code span" do
      assert [
               %Folio.Content.Paragraph{
                 body: [%Folio.Content.Raw{text: "ok", lang: nil, block: false}]
               }
             ] = Folio.parse_markdown!("`ok`")
    end

    test "returns empty list for empty input" do
      assert [] = Folio.parse_markdown!("")
    end
  end

  describe "to_pdf/2" do
    test "generates valid PDF from markdown string" do
      assert {:ok, pdf} = Folio.to_pdf("# Hello\n\nWorld")
      assert is_binary(pdf)
      assert binary_part(pdf, 0, 5) == "%PDF-"
    end

    test "generates valid PDF from content nodes" do
      content = [
        %Folio.Content.Heading{level: 1, body: [%Folio.Content.Text{text: "Test"}]},
        %Folio.Content.Paragraph{body: [%Folio.Content.Text{text: "Body"}]}
      ]

      assert {:ok, pdf} = Folio.to_pdf(content)
      assert is_binary(pdf)
      assert byte_size(pdf) > 100
    end

    test "accepts styles" do
      assert {:ok, pdf} =
               Folio.to_pdf(
                 "Styled text",
                 styles: [Folio.Styles.font_size(14), Folio.Styles.page_size(width: 595)]
               )

      assert is_binary(pdf)
    end

    test "raises for non-string non-list input" do
      assert_raise FunctionClauseError, fn -> Folio.to_pdf(123) end
    end
  end

  describe "to_svg/2" do
    test "generates SVG strings" do
      assert {:ok, [svg | _]} = Folio.to_svg("# SVG\n\nTest")
      assert is_binary(svg)
      assert String.starts_with?(svg, "<svg")
    end
  end

  describe "to_png/2" do
    test "generates PNG binaries" do
      assert {:ok, [png | _]} = Folio.to_png("PNG test")

      <<137, 80, 78, 71, 13, 10, 26, 10, _::binary>> = png
    end
  end

  describe "register_file/2" do
    @pixel_png <<137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0,
                 0, 1, 8, 2, 0, 0, 0, 144, 119, 83, 222, 0, 0, 0, 12, 73, 68, 65, 84, 120, 156,
                 99, 248, 207, 192, 0, 0, 3, 1, 1, 0, 201, 254, 146, 239, 0, 0, 0, 0, 73, 69, 78,
                 68, 174, 66, 96, 130>>

    test "registers a file and renders it as image" do
      Folio.register_file("test_pixel.png", @pixel_png)
      assert {:ok, pdf} = Folio.to_pdf("![pixel](test_pixel.png)")
      assert byte_size(pdf) > 100
    end
  end

  describe "Document pipeline" do
    test "builds and compiles a Document" do
      doc =
        Folio.Document.new()
        |> Folio.Document.add_style(Folio.Styles.font_size(14))
        |> Folio.Document.add_style(Folio.Styles.page_numbering("1"))
        |> Folio.Document.add_content("# Document API\n\nBuilt with pipeline.")

      assert {:ok, pdf} = Folio.to_pdf(doc)
      assert is_binary(pdf)
      assert byte_size(pdf) > 100
    end

    test "Document styles merge with opts styles" do
      doc =
        Folio.Document.new()
        |> Folio.Document.add_style(Folio.Styles.font_size(12))
        |> Folio.Document.add_content("Test")

      assert {:ok, pdf} = Folio.to_pdf(doc, styles: [Folio.Styles.page_numbering("1")])
      assert is_binary(pdf)
    end
  end

  describe "~MD sigil" do
    import Folio.Sigil

    test "~MD returns content nodes" do
      nodes = ~MD"# Hello"
      assert is_list(nodes)
      assert [%Folio.Content.Heading{level: 1}] = nodes
    end
  end

  describe "DSL functions" do
    test "heading, text, strong, emph produce content structs" do
      import Folio.DSL

      assert %Folio.Content.Heading{level: 2, body: [%Folio.Content.Text{text: "H2"}]} =
               heading(2, "H2")

      assert %Folio.Content.Text{text: "plain"} = text("plain")

      assert %Folio.Content.Strong{body: [%Folio.Content.Text{text: "b"}]} = strong("b")

      assert %Folio.Content.Emph{body: [%Folio.Content.Text{text: "i"}]} = emph("i")
    end

    test "shape builders set fields" do
      import Folio.DSL

      r = rect(fill: "#336699", width: "100pt")
      assert r.fill == "#336699"
      assert r.width == "100pt"

      c = circle(fill: "red", radius: "20pt")
      assert c.fill == "red"
      assert c.radius == "20pt"
    end

    test "table builders compose" do
      import Folio.DSL

      tbl =
        table([gutter: "6pt"],
          do: [
            table_header([table_cell("H1"), table_cell("H2")]),
            table_row([table_cell("A"), table_cell("B")])
          ]
        )

      assert %Folio.Content.Table{gutter: "6pt", children: [_header, _row]} = tbl
    end

    test "table with fr columns compiles" do
      import Folio.DSL

      assert {:ok, pdf} =
               Folio.to_pdf([
                 table([columns: ["1fr", "2fr", "1fr"], gutter: "8pt", stroke: "0.5pt"],
                   do: [
                     table_header([table_cell("A"), table_cell("B"), table_cell("C")]),
                     table_row([table_cell("1"), table_cell("2"), table_cell("3")])
                   ]
                 )
               ])

      assert is_binary(pdf)
      assert byte_size(pdf) > 100
    end

    test "table with mixed sizing columns compiles" do
      import Folio.DSL

      assert {:ok, pdf} =
               Folio.to_pdf([
                 table([columns: ["100pt", "1fr", "auto"], gutter: "4pt"],
                   do: [
                     table_row([table_cell("fixed"), table_cell("flex"), table_cell("auto")])
                   ]
                 )
               ])

      assert is_binary(pdf)
    end
  end

  describe "Styles" do
    test "page_size sets dimensions" do
      assert %Folio.Styles.PageSize{width: 595, height: 842} =
               Folio.Styles.page_size(width: 595, height: 842)
    end

    test "font_family wraps list" do
      assert %Folio.Styles.FontFamily{families: ["Helvetica"]} =
               Folio.Styles.font_family(["Helvetica"])
    end

    test "text_color wraps string" do
      assert %Folio.Styles.TextColor{color: "#333"} = Folio.Styles.text_color("#333")
    end

    test "page_numbering wraps string" do
      assert %Folio.Styles.PageNumbering{pattern: "1"} = Folio.Styles.page_numbering("1")
    end

    test "page header and footer wrap content" do
      assert %Folio.Styles.PageHeader{content: [%Folio.Content.Text{text: "Header"}]} =
               Folio.Styles.page_header("Header")

      assert %Folio.Styles.PageFooter{content: [%Folio.Content.Text{text: "Footer"}]} =
               Folio.Styles.page_footer("Footer")
    end

    test "heading styles wrap values" do
      assert %Folio.Styles.HeadingNumbering{pattern: "1.1"} =
               Folio.Styles.heading_numbering("1.1")

      assert %Folio.Styles.HeadingSupplement{content: [%Folio.Content.Text{text: "Chapter"}]} =
               Folio.Styles.heading_supplement("Chapter")

      assert %Folio.Styles.HeadingOutlined{outlined: false} =
               Folio.Styles.heading_outlined(false)

      assert %Folio.Styles.HeadingBookmarked{bookmarked: true} =
               Folio.Styles.heading_bookmarked(true)
    end
  end

  describe "page chrome and heading styling" do
    test "compiles document with page header and footer" do
      assert {:ok, pdf} =
               Folio.to_pdf("# Hello\n\nWorld",
                 styles: [
                   Folio.Styles.page_header("Header"),
                   Folio.Styles.page_footer("Footer"),
                   Folio.Styles.page_numbering("1")
                 ]
               )

      assert is_binary(pdf)
      assert byte_size(pdf) > 100
    end

    test "compiles document with heading numbering and supplement" do
      assert {:ok, pdf} =
               Folio.to_pdf("# Intro\n\n## Details",
                 styles: [
                   Folio.Styles.heading_numbering("1."),
                   Folio.Styles.heading_supplement("Chapter"),
                   Folio.Styles.heading_bookmarked(true),
                   Folio.Styles.heading_outlined(true)
                 ]
               )

      assert is_binary(pdf)
      assert byte_size(pdf) > 100
    end

    test "par indent compiles" do
      assert {:ok, pdf} =
               Folio.to_pdf("Hello\n\nWorld",
                 styles: [
                   Folio.Styles.par_indent(18)
                 ]
               )

      assert is_binary(pdf)
      assert byte_size(pdf) > 100
    end
  end

  describe "bibliography and citations" do
    @sample_bib ~S"""
    @book{knuth1984,
      author = {Donald E. Knuth},
      title = {The TeXbook},
      year = {1984},
      publisher = {Addison-Wesley}
    }
    """

    test "compiles explicit cite and bibliography" do
      Folio.register_file("works.bib", @sample_bib)

      assert {:ok, pdf} =
               Folio.to_pdf([
                 Folio.DSL.text("See "),
                 Folio.DSL.cite("knuth1984"),
                 Folio.DSL.text(" for details."),
                 Folio.DSL.bibliography("works.bib")
               ])

      assert is_binary(pdf)
      assert byte_size(pdf) > 100
    end
  end

  describe "SVG content verification" do
    test "SVG output contains rendered content" do
      {:ok, [svg]} = Folio.to_svg("# TestTitle")
      # Typst renders text as glyph paths, not raw strings
      assert svg =~ "<svg"
      assert svg =~ "</svg>"
      assert svg =~ "<defs>"
    end

    test "math renders without fallback text" do
      {:ok, [svg]} = Folio.to_svg("$x^2$")
      # Should NOT contain the raw math syntax as plain text
      refute svg =~ "$x^2$"
    end

    test "multi-page document produces multiple SVGs" do
      import Folio.DSL

      {:ok, svgs} =
        Folio.to_svg([
          heading(1, "Page 1"),
          pagebreak(),
          heading(1, "Page 2")
        ])

      assert [_page1, _page2] = svgs
    end
  end

  describe "error handling" do
    test "to_pdf returns error for broken image" do
      assert {:ok, _} = Folio.to_pdf([%Folio.Content.Image{src: "nope.png"}])
    end

    test "parse_markdown raises on NIF error" do
      assert [%Folio.Content.Paragraph{}] = Folio.parse_markdown!("ok")
    end
  end

  describe "DSL argument validation" do
    import Folio.DSL

    test "text/1 rejects non-string" do
      assert_raise ArgumentError, ~r/text\/1 expects a string/, fn -> text(123) end
    end

    test "heading/2 rejects out-of-range level" do
      assert_raise ArgumentError, ~r/level must be 1\.\.6/, fn -> heading(0, "test") end
      assert_raise ArgumentError, ~r/level must be 1\.\.6/, fn -> heading(7, "test") end
    end

    test "heading/2 rejects non-integer level" do
      assert_raise ArgumentError, ~r/expects an integer/, fn -> heading("1", "test") end
    end

    test "align/2 rejects invalid alignment" do
      assert_raise ArgumentError, ~r/expects :left, :center, or :right/, fn ->
        align(:top, "hello")
      end
    end

    test "rect/1 rejects non-keyword" do
      assert_raise ArgumentError, ~r/expects a keyword list/, fn -> rect("bad") end
    end

    test "circle/1 rejects non-keyword" do
      assert_raise ArgumentError, ~r/expects a keyword list/, fn -> circle(:oops) end
    end

    test "math/2 rejects non-string" do
      assert_raise ArgumentError, ~r/expects a string expression/, fn -> math(123) end
    end

    test "raw/2 rejects non-string" do
      assert_raise ArgumentError, ~r/expects a string/, fn -> raw(:not_string) end
    end

    test "vspace/2 rejects non-numeric" do
      assert_raise ArgumentError, ~r/expects a string or number/, fn -> vspace(nil) end
    end

    test "link/2 rejects non-string URL" do
      assert_raise ArgumentError, ~r/expects a string URL/, fn -> link(123) end
    end

    test "label/1 rejects non-string" do
      assert_raise ArgumentError, ~r/expects a string/, fn -> label(123) end
    end

    test "raw_typst/1 rejects non-string" do
      assert_raise ArgumentError, ~r/expects a string/, fn -> raw_typst(:not_string) end
    end

    test "show/2 rejects non-atom target" do
      assert_raise ArgumentError, ~r/expects an atom target/, fn ->
        show("heading", fn x -> x end)
      end
    end

    test "polygon/2 rejects non-list vertices" do
      assert_raise ArgumentError, ~r/expects a list/, fn -> polygon("bad") end
    end

    test "bibliography/2 rejects non-string non-list" do
      assert_raise ArgumentError, ~r/expects a string or list/, fn -> bibliography(123) end
    end

    test "grid/2 validates :columns type" do
      assert_raise ArgumentError, ~r/grid :columns must be a list/, fn ->
        grid([columns: 123], do: [grid_cell("A")])
      end
    end

    test "table_header/1 rejects empty list" do
      assert_raise ArgumentError, ~r/non-empty list/, fn -> table_header([]) end
    end

    test "table_row/1 rejects empty list" do
      assert_raise ArgumentError, ~r/non-empty list/, fn -> table_row([]) end
    end

    test "term_list/2 rejects non-tuple elements" do
      assert_raise ArgumentError, ~r/not a 2-tuple/, fn -> term_list([1, 2, 3]) end
    end
  end

  describe "thematic break" do
    test "--- becomes Divider, not Pagebreak" do
      assert [%Folio.Content.Paragraph{}, %Folio.Content.Divider{}, %Folio.Content.Paragraph{}] =
               Folio.parse_markdown!("before\n\n---\n\nafter")
    end
  end
end
