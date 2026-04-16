defmodule FolioTest do
  use ExUnit.Case, async: true

  describe "parse_markdown/1" do
    test "parses plain text paragraph" do
      assert [%Folio.Content.Paragraph{body: [%Folio.Content.Text{text: "hello"}]}] =
               Folio.parse_markdown("hello")
    end

    test "parses heading with level" do
      assert [%Folio.Content.Heading{level: 1, body: [%Folio.Content.Text{text: "Title"}]}] =
               Folio.parse_markdown("# Title")
    end

    test "parses strong and emph" do
      assert [%Folio.Content.Paragraph{
               body: [%Folio.Content.Strong{body: [%Folio.Content.Text{text: "bold"}]}]
             }] = Folio.parse_markdown("**bold**")

      assert [%Folio.Content.Paragraph{
               body: [%Folio.Content.Emph{body: [%Folio.Content.Text{text: "it"}]}]
             }] = Folio.parse_markdown("*it*")
    end

    test "parses link" do
      assert [%Folio.Content.Paragraph{
               body: [%Folio.Content.Link{url: "https://example.com", body: body}]
             }] = Folio.parse_markdown("[click](https://example.com)")

      assert [%Folio.Content.Text{text: "click"}] = body
    end

    test "parses image" do
      assert [%Folio.Content.Paragraph{
               body: [%Folio.Content.Image{src: "photo.png"}]
             }] = Folio.parse_markdown("![photo](photo.png)")
    end

    test "parses table" do
      md = "| A | B |\n|---|---|\n| 1 | 2 |"

      assert [%Folio.Content.Table{children: children}] = Folio.parse_markdown(md)
      assert length(children) == 2
    end

    test "parses block math" do
      assert [%Folio.Content.Paragraph{
               body: [%Folio.Content.Math{content: "E = m c ^2", block: true}]
             }] = Folio.parse_markdown("$$E = m c ^2$$")
    end

    test "parses inline math" do
      assert [%Folio.Content.Paragraph{
               body: [%Folio.Content.Math{content: "x", block: false}]
             }] = Folio.parse_markdown("$x$")
    end

    test "parses strikethrough" do
      assert [%Folio.Content.Paragraph{
               body: [%Folio.Content.Strike{body: [%Folio.Content.Text{text: "gone"}]}]
             }] = Folio.parse_markdown("~~gone~~")
    end

    test "parses code block" do
      assert [%Folio.Content.Raw{text: "x = 1\n", lang: "elixir", block: true}] =
               Folio.parse_markdown("```elixir\nx = 1\n```")
    end

    test "parses blockquote" do
      assert [%Folio.Content.Quote{body: body}] = Folio.parse_markdown("> wisdom")
      assert [%Folio.Content.Paragraph{body: [%Folio.Content.Text{text: "wisdom"}]}] = body
    end

    test "parses code span" do
      assert [%Folio.Content.Paragraph{
               body: [%Folio.Content.Raw{text: "ok", lang: nil, block: false}]
             }] = Folio.parse_markdown("`ok`")
    end

    test "returns empty list for empty input" do
      assert [] = Folio.parse_markdown("")
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
      assert {:ok, svgs} = Folio.to_svg("# SVG\n\nTest")
      assert is_list(svgs)
      assert length(svgs) >= 1
      assert String.starts_with?(hd(svgs), "<svg")
    end
  end

  describe "to_png/2" do
    test "generates PNG binaries" do
      assert {:ok, pngs} = Folio.to_png("PNG test")
      assert is_list(pngs)
      assert length(pngs) >= 1

      <<137, 80, 78, 71, 13, 10, 26, 10, _::binary>> = hd(pngs)
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
    test "~MD returns content nodes" do
      use Folio
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
        table([gutter: "6pt"], do: [
          table_header([table_cell("H1"), table_cell("H2")]),
          table_row([table_cell("A"), table_cell("B")])
        ])

      assert %Folio.Content.Table{gutter: "6pt", children: children} = tbl
      assert length(children) == 2
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
  end
end
