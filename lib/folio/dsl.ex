defmodule Folio.DSL do
  @moduledoc """
  Builder functions for Folio content nodes.

  Every function returns a `%Folio.Content.*{}` struct.
  Use inside `\#{}` interpolation in `~MD` sigils, or directly in Elixir code.

      use Folio
      content = [heading(1, "Title"), text("Hello"), strong("world")]
      {:ok, pdf} = Folio.to_pdf(content)
  """

  alias Folio.Content

  # ── Text ──

  @doc """
  Create a text node. Options: `:size`, `:weight`, `:fill`, `:tracking`.

  ## Examples

      use Folio
      text("Hello, world!")
      text("Big", size: "24pt", weight: "bold", fill: "#ff0000")
  """
  @spec text(String.t(), keyword()) :: Content.Text.t()
  def text(str, opts \\ [])

  def text(str, opts) when is_binary(str) and is_list(opts) do
    %Content.Text{
      text: str,
      size: Keyword.get(opts, :size),
      weight: Keyword.get(opts, :weight),
      fill: Keyword.get(opts, :fill),
      tracking: Keyword.get(opts, :tracking)
    }
  end

  def text(str, opts),
    do:
      raise(ArgumentError,
        message: "text/2 expects a string and keyword list, got: #{inspect({str, opts})}"
      )

  # ── Headings ──

  @doc """
  Create a heading (levels 1-6).

  ## Examples

      use Folio
      heading(1, "Introduction")
      heading(2, [strong("Bold"), text(" subtitle")])
  """
  @spec heading(1..6, Content.t() | [Content.t()] | String.t()) :: Content.Heading.t()
  def heading(level, content) when is_integer(level) and level >= 1 and level <= 6 do
    %Content.Heading{level: level, body: Content.to_content(content)}
  end

  def heading(level, _content) when is_integer(level) do
    raise(ArgumentError, message: "heading/2 level must be 1..6, got: #{level}")
  end

  def heading(level, _content) do
    raise(ArgumentError,
      message: "heading/2 expects an integer level (1..6), got: #{inspect(level)}"
    )
  end

  @doc """
  Cite a bibliography entry.

      cite("knuth1984", form: "prose")
  """
  @spec cite(String.t(), keyword()) :: Content.Cite.t()
  def cite(key, opts \\ [])

  def cite(key, opts) when is_binary(key) and is_list(opts) do
    %Content.Cite{
      key: key,
      supplement: then_if_some(Keyword.get(opts, :supplement), &Content.to_content/1),
      form: Keyword.get(opts, :form),
      style: Keyword.get(opts, :style)
    }
  end

  def cite(key, opts) do
    raise ArgumentError,
          "cite/2 expects a string key and a keyword list, got: #{inspect({key, opts})}"
  end

  @doc """
  Insert a bibliography listing.

      bibliography("refs.bib", title: "References", style: "ieee")
  """
  @spec bibliography(String.t() | [String.t()], keyword()) :: Content.Bibliography.t()
  def bibliography(sources, opts \\ [])

  def bibliography(sources, opts) when is_binary(sources) and is_list(opts) do
    do_bibliography([sources], opts)
  end

  def bibliography(sources, opts) when is_list(sources) and is_list(opts) do
    do_bibliography(sources, opts)
  end

  def bibliography(sources, opts) do
    raise ArgumentError,
          "bibliography/2 expects a string or list of strings as the first argument, got: #{inspect(sources, opts)}"
  end

  defp do_bibliography(sources, opts) do
    %Content.Bibliography{
      sources: sources,
      title: then_if_some(Keyword.get(opts, :title), &Content.to_content/1),
      full: Keyword.get(opts, :full, false),
      style: Keyword.get(opts, :style)
    }
  end

  # ── Inline formatting ──

  @doc """
  Bold text.

  ## Examples

      use Folio
      strong("important")
      strong([text("also "), emph("works")])
  """
  @spec strong(Content.t() | [Content.t()] | String.t()) :: Content.Strong.t()
  def strong(content), do: %Content.Strong{body: Content.to_content(content)}

  @doc """
  Italic text.

  ## Examples

      use Folio
      emph("emphasis")
  """
  @spec emph(Content.t() | [Content.t()] | String.t()) :: Content.Emph.t()
  def emph(content), do: %Content.Emph{body: Content.to_content(content)}

  @doc """
  Strikethrough text.

  ## Examples

      use Folio
      strike("deleted")
  """
  @spec strike(Content.t() | [Content.t()] | String.t()) :: Content.Strike.t()
  def strike(content), do: %Content.Strike{body: Content.to_content(content)}

  @doc """
  Underlined text.

  ## Examples

      use Folio
      underline("underlined")
  """
  @spec underline(Content.t() | [Content.t()] | String.t()) :: Content.Underline.t()
  def underline(content), do: %Content.Underline{body: Content.to_content(content)}

  @doc """
  Highlighted text. Options: `:fill` color.

  ## Examples

      use Folio
      highlight("important passage")
      highlight("custom color", fill: "#ffff00")
  """
  @spec highlight(Content.t() | [Content.t()] | String.t(), keyword()) :: Content.Highlight.t()
  def highlight(content, opts \\ []) when is_list(opts) do
    %Content.Highlight{body: Content.to_content(content), fill: Keyword.get(opts, :fill)}
  end

  @doc """
  Superscript text.

  ## Examples

      use Folio
      [text("x"), superscript("2")]
  """
  @spec superscript(Content.t() | [Content.t()] | String.t()) :: Content.Super.t()
  def superscript(content), do: %Content.Super{body: Content.to_content(content)}

  @doc """
  Subscript text.

  ## Examples

      use Folio
      [text("H"), subscript("2"), text("O")]
  """
  @spec subscript(Content.t() | [Content.t()] | String.t()) :: Content.Sub.t()
  def subscript(content), do: %Content.Sub{body: Content.to_content(content)}

  @doc """
  Small capitals text.

  ## Examples

      use Folio
      smallcaps("Section Title")
  """
  @spec smallcaps(Content.t() | [Content.t()] | String.t()) :: Content.Smallcaps.t()
  def smallcaps(content), do: %Content.Smallcaps{body: Content.to_content(content)}

  # ── Images ──

  @doc """
  Embed an image. Options: `:width`, `:height`, `:fit` ("contain"/"cover"/"stretch").
  """
  @spec image(String.t(), keyword()) :: Content.Image.t()
  def image(src, opts \\ [])

  def image(src, opts) when is_binary(src) and is_list(opts) do
    %Content.Image{
      src: src,
      width: Keyword.get(opts, :width),
      height: Keyword.get(opts, :height),
      fit: Keyword.get(opts, :fit)
    }
  end

  def image(src, opts) do
    raise ArgumentError,
          "image/2 expects a string source and a keyword list, got: #{inspect({src, opts})}"
  end

  # ── Figures ──

  @doc """
  Wrap content in a figure. Options: `:caption`, `:placement` ("top"/"bottom"), `:scope`, `:numbering`.
  """
  @spec figure(Content.t() | [Content.t()] | String.t(), keyword()) :: Content.Figure.t()
  def figure(content, opts \\ [])

  def figure(content, opts)
      when (is_binary(content) or is_struct(content) or is_list(content)) and is_list(opts) do
    %Content.Figure{
      body: Content.to_content(content),
      caption: then_if_some(Keyword.get(opts, :caption), &Content.to_content/1),
      placement: Keyword.get(opts, :placement),
      scope: Keyword.get(opts, :scope),
      numbering: Keyword.get(opts, :numbering),
      separator: Keyword.get(opts, :separator)
    }
  end

  def figure(content, opts) do
    raise ArgumentError,
          "figure/2 expects content (string, struct, or list) and a keyword list, got: #{inspect({content, opts})}"
  end

  # ── Tables ──

  @doc """
  Create a table. Options: `:columns`, `:rows`, `:stroke`, `:gutter`, `:align`. Use `do` block for rows.

  ## Examples

      use Folio
      table(columns: ["1fr", "1fr"],
        do: [
          table_header(["Name", "Score"]),
          table_row(["Alice", "95"]),
          table_row(["Bob", "87"])
        ])
  """
  @spec table(keyword(), [{:do, [Content.t()]}]) :: Content.Table.t()
  def table(opts, do: children) when is_list(opts) do
    columns =
      case Keyword.get(opts, :columns) do
        nil ->
          nil

        cols when is_list(cols) ->
          Enum.map(cols, &to_string/1)

        col when is_binary(col) ->
          [col]

        other ->
          raise ArgumentError,
                "table :columns must be a list of sizing strings (e.g. [\"1fr\", \"1fr\", \"1fr\"]) or a single string, got: #{inspect(other)}"
      end

    %Content.Table{
      columns: columns,
      rows: Keyword.get(opts, :rows),
      children: Content.flatten(Content.to_content(children)),
      stroke: Keyword.get(opts, :stroke),
      gutter: Keyword.get(opts, :gutter),
      align: Keyword.get(opts, :align),
      inset: Keyword.get(opts, :inset),
      fill: Keyword.get(opts, :fill)
    }
  end

  @doc """
  Create a table header row from a list of cell contents.

  ## Examples

      use Folio
      table_header(["Name", "Age", "City"])
  """
  @spec table_header([Content.t() | String.t()]) :: Content.TableHeader.t()
  def table_header([_ | _] = cells) do
    %Content.TableHeader{children: Enum.map(cells, &table_cell/1)}
  end

  def table_header(cells) do
    raise ArgumentError,
          "table_header/1 expects a non-empty list of cell contents, got: #{inspect(cells)}"
  end

  @doc """
  Create a table data row from a list of cell contents.

  ## Examples

      use Folio
      table_row(["Alice", "30", "London"])
  """
  @spec table_row([Content.t() | String.t()]) :: Content.TableRow.t()
  def table_row([_ | _] = cells) do
    %Content.TableRow{children: Enum.map(cells, &table_cell/1)}
  end

  def table_row(cells) do
    raise ArgumentError,
          "table_row/1 expects a non-empty list of cell contents, got: #{inspect(cells)}"
  end

  @doc """
  Create a table cell. Options: `:colspan`, `:rowspan`, `:align`.

  ## Examples

      use Folio
      table_cell("plain cell")
      table_cell(strong("header"), colspan: 2, align: "center")
  """
  @spec table_cell(Content.t() | [Content.t()] | String.t(), keyword()) :: Content.TableCell.t()
  def table_cell(content, opts \\ []) when is_list(opts) do
    %Content.TableCell{
      body: Content.to_content(content),
      colspan: Keyword.get(opts, :colspan),
      rowspan: Keyword.get(opts, :rowspan),
      align: Keyword.get(opts, :align),
      fill: Keyword.get(opts, :fill),
      stroke: Keyword.get(opts, :stroke)
    }
  end

  # ── Layout ──

  @doc """
  Flow content into `count` columns. Options: `:gutter`.

  ## Examples

      use Folio
      columns(2, gutter: "12pt",
        do: [
          text("Left column content."),
          colbreak(),
          text("Right column content.")
        ])
  """
  @spec columns(pos_integer(), keyword(), [{:do, [Content.t()]}]) :: Content.Columns.t()
  def columns(count, opts \\ [], do: body)
      when is_integer(count) and count >= 1 and is_list(opts) do
    %Content.Columns{
      count: count,
      body: Content.flatten(Content.to_content(body)),
      gutter: Keyword.get(opts, :gutter)
    }
  end

  @doc """
  Force a column break. Options: `:weak`.

  ## Examples

      use Folio
      colbreak()
      colbreak(weak: true)
  """
  @spec colbreak(keyword()) :: Content.Colbreak.t()
  def colbreak(opts \\ []), do: %Content.Colbreak{weak: Keyword.get(opts, :weak, false)}

  @doc """
  Force a page break. Options: `:weak`.

  ## Examples

      use Folio
      pagebreak()
      pagebreak(weak: true)
  """
  @spec pagebreak(keyword()) :: Content.Pagebreak.t()
  def pagebreak(opts \\ []), do: %Content.Pagebreak{weak: Keyword.get(opts, :weak, false)}

  @doc """
  Insert a paragraph break.

  ## Examples

      use Folio
      [text("First paragraph."), parbreak(), text("Second paragraph.")]
  """
  @spec parbreak() :: Content.Parbreak.t()
  def parbreak, do: %Content.Parbreak{}

  @doc """
  Insert a line break.

  ## Examples

      use Folio
      [text("Line one."), linebreak(), text("Line two.")]
  """
  @spec linebreak() :: Content.Linebreak.t()
  def linebreak, do: %Content.Linebreak{}

  @doc """
  Align content. Accepts `:left`, `:center`, `:right` or string equivalents.

  ## Examples

      use Folio
      align(:center, heading(1, "Centered Title"))
      align(:right, text("Right-aligned"))
  """
  @spec align(atom() | String.t(), Content.t() | [Content.t()] | String.t()) :: Content.Align.t()
  def align(alignment, content)
      when alignment in [:left, :center, :right, "left", "center", "right"] do
    %Content.Align{alignment: to_string(alignment), body: Content.to_content(content)}
  end

  def align(alignment, _content) do
    raise ArgumentError,
          "align/2 expects :left, :center, or :right as the first argument, got: #{inspect(alignment)}"
  end

  @doc """
  Block-level container. Options: `:width`, `:height`, `:above`, `:below`.

  ## Examples

      use Folio
      block(above: "1em", below: "1em",
        do: [text("Spaced block content.")])
  """
  @spec block(keyword(), [{:do, [Content.t()]}]) :: Content.Block.t()
  def block(opts \\ [], do: body) when is_list(opts) do
    %Content.Block{
      body: Content.flatten(Content.to_content(body)),
      width: Keyword.get(opts, :width),
      height: Keyword.get(opts, :height),
      above: Keyword.get(opts, :above),
      below: Keyword.get(opts, :below),
      fill: Keyword.get(opts, :fill),
      inset: Keyword.get(opts, :inset),
      radius: Keyword.get(opts, :radius),
      stroke: Keyword.get(opts, :stroke)
    }
  end

  @doc """
  Hide content (invisible but takes space).

  ## Examples

      use Folio
      hide(text("placeholder"))
  """
  @spec hide(Content.t() | [Content.t()] | String.t()) :: Content.Hide.t()
  def hide(content), do: %Content.Hide{body: Content.to_content(content)}

  @doc """
  Repeat content to fill available space.

  ## Examples

      use Folio
      repeat(text("."))
  """
  @spec repeat(Content.t() | [Content.t()] | String.t()) :: Content.Repeat.t()
  def repeat(content), do: %Content.Repeat{body: Content.to_content(content)}

  @doc """
  Place content at an alignment. Options: `:alignment`, `:float`.

  ## Examples

      use Folio
      place(image("logo.png"), alignment: "top + right", float: true)
  """
  @spec place(Content.t() | [Content.t()] | String.t(), keyword()) :: Content.Place.t()
  def place(content, opts \\ []) when is_list(opts) do
    %Content.Place{
      alignment: Keyword.get(opts, :alignment),
      body: Content.to_content(content),
      float: Keyword.get(opts, :float)
    }
  end

  @doc """
  Vertical spacing. Options: `:weak`.

  ## Examples

      use Folio
      vspace("1em")
      vspace("2pt", weak: true)
  """
  @spec vspace(String.t() | number(), keyword()) :: Content.VSpace.t()
  def vspace(amount, opts \\ [])

  def vspace(amount, opts) when (is_binary(amount) or is_number(amount)) and is_list(opts) do
    %Content.VSpace{amount: to_string(amount), weak: Keyword.get(opts, :weak, false)}
  end

  def vspace(amount, opts) do
    raise ArgumentError,
          "vspace/2 expects a string or number as the amount, got: #{inspect({amount, opts})}"
  end

  @doc """
  Horizontal spacing. Options: `:weak`.

  ## Examples

      use Folio
      hspace("1em")
      hspace("0.5cm", weak: true)
  """
  @spec hspace(String.t() | number(), keyword()) :: Content.HSpace.t()
  def hspace(amount, opts \\ [])

  def hspace(amount, opts) when (is_binary(amount) or is_number(amount)) and is_list(opts) do
    %Content.HSpace{amount: to_string(amount), weak: Keyword.get(opts, :weak, false)}
  end

  def hspace(amount, opts) do
    raise ArgumentError,
          "hspace/2 expects a string or number as the amount, got: #{inspect({amount, opts})}"
  end

  @doc """
  Add padding around content. Options: `:left`, `:right`, `:top`, `:bottom`.

  ## Examples

      use Folio
      pad(left: "1cm", right: "1cm",
        do: [text("Indented paragraph.")])
  """
  @spec pad(keyword(), [{:do, [Content.t()]}]) :: Content.Pad.t()
  def pad(opts, do: body) when is_list(opts) do
    %Content.Pad{
      body: Content.flatten(Content.to_content(body)),
      left: Keyword.get(opts, :left),
      right: Keyword.get(opts, :right),
      top: Keyword.get(opts, :top),
      bottom: Keyword.get(opts, :bottom)
    }
  end

  @doc """
  Stack children in a direction. Options: `:dir` ("ttb"/"ltr"/"rtl"/"btt"), `:spacing`.
  """
  @spec stack(keyword(), [{:do, [Content.t()]}]) :: Content.Stack.t()
  def stack(opts, do: children) when is_list(opts) do
    %Content.Stack{
      dir: Keyword.get(opts, :dir, "ttb"),
      children: Content.flatten(Content.to_content(children)),
      spacing: Keyword.get(opts, :spacing)
    }
  end

  # ── Shapes ──

  @doc """
  Rectangle. Options: `:width`, `:height`, `:fill`, `:body`.

  ## Examples

      use Folio
      rect(width: "100pt", height: "50pt", fill: "#cccccc")
      rect(width: "4cm", body: text("inside"))
  """
  @spec rect(keyword()) :: Content.Rect.t()
  def rect(opts \\ [])

  def rect(opts) when is_list(opts) do
    %Content.Rect{
      body: shape_body(opts),
      width: Keyword.get(opts, :width),
      height: Keyword.get(opts, :height),
      fill: Keyword.get(opts, :fill),
      inset: Keyword.get(opts, :inset),
      radius: Keyword.get(opts, :radius)
    }
  end

  def rect(opts) do
    raise ArgumentError, "rect/1 expects a keyword list of options, got: #{inspect(opts)}"
  end

  @doc """
  Square. Options: `:size`, `:fill`, `:body`.

  ## Examples

      use Folio
      square(size: "40pt", fill: "#0055bb")
  """
  @spec square(keyword()) :: Content.Square.t()
  def square(opts \\ [])

  def square(opts) when is_list(opts) do
    %Content.Square{
      body: shape_body(opts),
      size: Keyword.get(opts, :size),
      fill: Keyword.get(opts, :fill)
    }
  end

  def square(opts) do
    raise ArgumentError, "square/1 expects a keyword list of options, got: #{inspect(opts)}"
  end

  @doc """
  Circle. Options: `:radius`, `:fill`, `:body`.

  ## Examples

      use Folio
      circle(radius: "20pt", fill: "#ff0000")
  """
  @spec circle(keyword()) :: Content.Circle.t()
  def circle(opts \\ [])

  def circle(opts) when is_list(opts) do
    %Content.Circle{
      body: shape_body(opts),
      radius: Keyword.get(opts, :radius),
      fill: Keyword.get(opts, :fill)
    }
  end

  def circle(opts) do
    raise ArgumentError, "circle/1 expects a keyword list of options, got: #{inspect(opts)}"
  end

  @doc """
  Ellipse. Options: `:width`, `:height`, `:fill`, `:body`.

  ## Examples

      use Folio
      ellipse(width: "80pt", height: "40pt", fill: "#aaffaa")
  """
  @spec ellipse(keyword()) :: Content.Ellipse.t()
  def ellipse(opts \\ [])

  def ellipse(opts) when is_list(opts) do
    %Content.Ellipse{
      body: shape_body(opts),
      width: Keyword.get(opts, :width),
      height: Keyword.get(opts, :height),
      fill: Keyword.get(opts, :fill)
    }
  end

  def ellipse(opts) do
    raise ArgumentError, "ellipse/1 expects a keyword list of options, got: #{inspect(opts)}"
  end

  @doc """
  Line. Options: `:start`, `:end`, `:length`, `:angle`, `:stroke`.

  ## Examples

      use Folio
      line(length: "100%", stroke: "1pt")
      line(start: "(0pt, 0pt)", end: "(50pt, 50pt)")
  """
  @spec line(keyword()) :: Content.Line.t()
  def line(opts \\ [])

  def line(opts) when is_list(opts) do
    %Content.Line{
      start: Keyword.get(opts, :start),
      end: Keyword.get(opts, :end),
      length: Keyword.get(opts, :length),
      angle: Keyword.get(opts, :angle),
      stroke: Keyword.get(opts, :stroke)
    }
  end

  def line(opts) do
    raise ArgumentError, "line/1 expects a keyword list of options, got: #{inspect(opts)}"
  end

  @doc """
  Polygon from coordinate list. Options: `:fill`, `:stroke`.

  ## Examples

      use Folio
      polygon([{0, 0}, {50, 0}, {25, 40}], fill: "#aaaaff", stroke: "1pt")
  """
  @spec polygon([{number(), number()}], keyword()) :: Content.Polygon.t()
  def polygon(vertices, opts \\ [])

  def polygon(vertices, opts) when is_list(vertices) and is_list(opts) do
    %Content.Polygon{
      vertices: Enum.map(vertices, &to_string/1),
      fill: Keyword.get(opts, :fill),
      stroke: Keyword.get(opts, :stroke)
    }
  end

  def polygon(vertices, opts) do
    raise ArgumentError,
          "polygon/2 expects a list of coordinate pairs and a keyword list, got: #{inspect({vertices, opts})}"
  end

  # ── Document structure ──

  @doc """
  Table of contents. Options: `:title`, `:indent`, `:depth`.

  ## Examples

      use Folio
      outline()
      outline(title: "Contents", depth: 2)
  """
  @spec outline(keyword()) :: Content.Outline.t()
  def outline(opts \\ [])

  def outline(opts) when is_list(opts) do
    %Content.Outline{
      title: Keyword.get(opts, :title),
      indent: Keyword.get(opts, :indent),
      depth: Keyword.get(opts, :depth)
    }
  end

  def outline(opts) do
    raise ArgumentError, "outline/1 expects a keyword list of options, got: #{inspect(opts)}"
  end

  @doc """
  Grid layout. Options: `:columns`, `:rows`, `:gutter`.
  Use `do` block for cells.

      grid(columns: ["1fr", "1fr"], gutter: "6pt",
        do: [grid_cell("A"), grid_cell("B")])
  """
  @spec grid(keyword(), [{:do, [Content.t()]}]) :: Content.Grid.t()
  def grid(opts, do: children) when is_list(opts) do
    columns = Keyword.get(opts, :columns)

    unless is_nil(columns) or is_list(columns) do
      raise ArgumentError,
            "grid :columns must be a list of strings (e.g. [\"1fr\", \"1fr\"]) or nil, got: #{inspect(columns)}"
    end

    rows = Keyword.get(opts, :rows)

    unless is_nil(rows) or is_list(rows) do
      raise ArgumentError,
            "grid :rows must be a list of strings or nil, got: #{inspect(rows)}"
    end

    normalized_columns =
      if is_list(columns) do
        Enum.map(columns, &to_string/1)
      else
        columns
      end

    %Content.Grid{
      columns: normalized_columns,
      rows: if(is_list(rows), do: Enum.map(rows, &to_string/1), else: rows),
      gutter: Keyword.get(opts, :gutter),
      column_gutter: Keyword.get(opts, :column_gutter),
      row_gutter: Keyword.get(opts, :row_gutter),
      children: Content.flatten(Content.to_content(children))
    }
  end

  @doc """
  Create a grid cell. Options: `:colspan`, `:rowspan`, `:align`, `:fill`.

  ## Examples

      use Folio
      grid_cell("plain")
      grid_cell(strong("header"), colspan: 2, fill: "#eeeeee")
  """
  @spec grid_cell(Content.t() | [Content.t()] | String.t(), keyword()) :: Content.GridCell.t()
  def grid_cell(content, opts \\ [])

  def grid_cell(content, opts) when is_list(opts) do
    %Content.GridCell{
      body: Content.to_content(content),
      colspan: Keyword.get(opts, :colspan),
      rowspan: Keyword.get(opts, :rowspan),
      align: Keyword.get(opts, :align),
      fill: Keyword.get(opts, :fill)
    }
  end

  def grid_cell(content, opts) do
    raise ArgumentError,
          "grid_cell/2 expects content and a keyword list of options, got: #{inspect({content, opts})}"
  end

  @doc """
  Document title.

  ## Examples

      use Folio
      title("My Report")
      title([strong("Folio"), text(" — PDF Library")])
  """
  @spec title(Content.t() | [Content.t()] | String.t()) :: Content.Title.t()
  def title(content), do: %Content.Title{body: Content.to_content(content)}

  @doc """
  Horizontal divider.

  ## Examples

      use Folio
      divider()
  """
  @spec divider() :: Content.Divider.t()
  def divider, do: %Content.Divider{}

  # ── Term lists ──

  @doc """
  Definition list from `{term, description}` tuples. Options: `:tight`.

  ## Examples

      use Folio
      term_list([
        {"Elixir", "A functional language."},
        {"Typst", "A modern typesetting system."}
      ])
  """
  @spec term_list([{term(), term()}], keyword()) :: Content.TermList.t()
  def term_list(items, opts \\ [])

  def term_list(items, opts) when is_list(items) and is_list(opts) do
    children =
      Enum.map(items, fn
        {term, desc} ->
          %Content.TermItem{term: Content.to_content(term), description: Content.to_content(desc)}

        other ->
          raise ArgumentError,
                "term_list/2 expects a list of {term, description} tuples, " <>
                  "but an element is not a 2-tuple: #{inspect(other)}"
      end)

    %Content.TermList{children: children, tight: Keyword.get(opts, :tight, true)}
  end

  def term_list(items, opts) do
    raise ArgumentError,
          "term_list/2 expects a list of tuples and a keyword list, got: #{inspect({items, opts})}"
  end

  @doc """
  Single term item.

  ## Examples

      use Folio
      term_item("Folio", "A PDF library for Elixir.")
  """
  @spec term_item(term(), term()) :: Content.TermItem.t()
  def term_item(term, description) do
    %Content.TermItem{
      term: Content.to_content(term),
      description: Content.to_content(description)
    }
  end

  # ── Footnotes ──

  @doc """
  Footnote.

  ## Examples

      use Folio
      [text("See here"), footnote("Additional details in the appendix.")]
  """
  @spec footnote(Content.t() | [Content.t()] | String.t()) :: Content.Footnote.t()
  def footnote(content), do: %Content.Footnote{body: Content.to_content(content)}

  # ── Lists ──

  @doc """
  Bullet list. Options: `:tight`, `:marker`.

  ## Examples

      use Folio
      list(["First item", "Second item", "Third item"])
      list(["A", "B"], tight: false, marker: "–")
  """
  @spec list([term()], keyword()) :: Content.List.t()
  def list(items, opts \\ [])

  def list(items, opts) when is_list(items) and is_list(opts) do
    %Content.List{
      children: Enum.map(items, &%Content.ListItem{body: Content.to_content(&1)}),
      tight: Keyword.get(opts, :tight, true),
      marker: Keyword.get(opts, :marker)
    }
  end

  def list(items, opts) do
    raise ArgumentError,
          "list/2 expects a list of items and a keyword list, got: #{inspect({items, opts})}"
  end

  @doc """
  Numbered list. Items can be plain content or `{number, content}` tuples.

      enum(["First", "Second"])                    # auto-numbered
      enum([{1, "First"}, {5, "Fifth"}])           # explicit numbers
      enum(["A", "B"], start: 3)                   # start from 3
  """
  @spec enum([term()], keyword()) :: Content.EnumList.t()
  def enum(items, opts \\ [])

  def enum(items, opts) when is_list(items) and is_list(opts) do
    %Content.EnumList{
      children:
        Enum.map(items, fn
          {num, content} -> %Content.EnumItem{body: Content.to_content(content), number: num}
          content -> %Content.EnumItem{body: Content.to_content(content), number: nil}
        end),
      tight: Keyword.get(opts, :tight, true),
      start: Keyword.get(opts, :start)
    }
  end

  def enum(items, opts) do
    raise ArgumentError,
          "enum/2 expects a list of items and a keyword list, got: #{inspect({items, opts})}"
  end

  # ── Links ──

  @doc """
  Hyperlink. Second argument is optional display text.

  ## Examples

      use Folio
      link("https://elixir-lang.org")
      link("https://elixir-lang.org", "Elixir")
      link("https://elixir-lang.org", strong("Elixir"))
  """
  @spec link(String.t(), nil | Content.t() | String.t()) :: Content.Link.t()
  def link(url, text \\ nil)

  def link(url, text) when is_binary(url) do
    %Content.Link{url: url, body: if(text, do: Content.to_content(text), else: [])}
  end

  def link(url, _text) do
    raise ArgumentError, "link/2 expects a string URL, got: #{inspect(url)}"
  end

  # ── Labels & References ──

  @doc """
  Label a position for cross-references.

  ## Examples

      use Folio
      [heading(1, "Introduction"), label("intro")]
  """
  @spec label(String.t()) :: Content.Label.t()
  def label(name) when is_binary(name), do: %Content.Label{name: name}

  def label(name) do
    raise ArgumentError, "label/1 expects a string, got: #{inspect(name)}"
  end

  @doc """
  Reference a labelled element.

  ## Examples

      use Folio
      ref("intro")
      ref("fig:chart", "Figure")
  """
  @spec ref(String.t(), nil | Content.t() | [Content.t()] | String.t()) :: Content.Ref.t()
  def ref(target, supplement \\ nil)

  def ref(target, supplement) when is_binary(target) do
    %Content.Ref{target: target, supplement: if(supplement, do: Content.to_content(supplement))}
  end

  def ref(target, _supplement) do
    raise ArgumentError, "ref/2 expects a string target label, got: #{inspect(target)}"
  end

  # ── Math ──

  @doc """
  Math expression in Typst syntax. Options: `:block`.

  ## Examples

      use Folio
      math("x^2 + y^2 = r^2")
      math("sum_(i=1)^n i = (n(n+1))/2", block: true)
  """
  @spec math(String.t(), keyword()) :: Content.Math.t()
  def math(content, opts \\ [])

  def math(content, opts) when is_binary(content) and is_list(opts) do
    %Content.Math{content: content, block: Keyword.get(opts, :block, false)}
  end

  def math(content, opts) do
    raise ArgumentError,
          "math/2 expects a string expression and a keyword list, got: #{inspect({content, opts})}"
  end

  # ── Raw / Code ──

  @doc """
  Raw/code text. Options: `:lang`, `:block`.

  ## Examples

      use Folio
      raw("IO.puts(\"hello\")", lang: "elixir")
      raw("SELECT * FROM users", lang: "sql", block: true)
  """
  @spec raw(String.t(), keyword()) :: Content.Raw.t()
  def raw(text, opts \\ [])

  def raw(text, opts) when is_binary(text) and is_list(opts) do
    %Content.Raw{
      text: text,
      lang: Keyword.get(opts, :lang),
      block: Keyword.get(opts, :block, true)
    }
  end

  def raw(text, opts) do
    raise ArgumentError,
          "raw/2 expects a string and a keyword list, got: #{inspect({text, opts})}"
  end

  @doc """
  Local style overrides for a content block.
  Mirrors Typst's `#set text(...)` / `#set par(...)` within a scope.

      local_set([hyphenate: false, justify: false],
        do: [text("No hyphenation here")])
  """
  @spec local_set(keyword(), [{:do, [Content.t()]}]) :: Content.LocalSet.t()
  def local_set(opts, do: body) when is_list(opts) do
    %Content.LocalSet{
      body: Content.flatten(Content.to_content(body)),
      hyphenate: Keyword.get(opts, :hyphenate),
      justify: Keyword.get(opts, :justify),
      first_line_indent: then_if_some(Keyword.get(opts, :first_line_indent), &(&1 / 1))
    }
  end

  @doc """
  Raw Typst source injected directly.

      raw_typst("#set text(hyphenate: false)\\nHello")
  """
  @spec raw_typst(String.t()) :: Content.RawTypst.t()
  def raw_typst(source) when is_binary(source) do
    %Content.RawTypst{source: source}
  end

  def raw_typst(source) do
    raise ArgumentError, "raw_typst/1 expects a string, got: #{inspect(source)}"
  end

  @doc """
  Create a show rule that transforms matching content elements.

  The target is an atom matching the content type. Common targets:
  `:enum`, `:enum_item`, `:list`, `:list_item`, `:heading`,
  `:paragraph`, `:quote`, `:table`, `:grid`, `:block`, etc.

  The transform receives the matched struct and returns replacement
  content (a struct, a list of structs, or a string).

  ## Example — custom enum formatting

      show(:enum, fn %Folio.Content.EnumList{children: items} ->
        items
        |> Enum.with_index(1)
        |> Enum.map(fn {item, num} ->
          block([above: "0.65em", below: "0.65em"],
            do: [
              local_set([first_line_indent: 0],
                do: [
                  hspace("1.25cm"),
                  text("\#{num}."),
                  hspace("0.3em"),
                  item.body
                ]
              )
            ]
          )
        end)
        |> List.flatten()
      end)
  """
  @spec show(atom(), (struct() -> Content.t() | [Content.t()] | String.t())) ::
          Content.ShowRule.t()
  def show(target, transform) when is_atom(target) and is_function(transform, 1) do
    %Content.ShowRule{target: target, transform: transform}
  end

  def show(target, transform) do
    raise ArgumentError,
          "show/2 expects an atom target and a 1-arity function, got: #{inspect({target, transform})}"
  end

  # ── Quote ──

  @doc """
  Block quote. Options: `:block`, `:attribution`.

  ## Examples

      use Folio
      blockquote("To be, or not to be.")
      blockquote("Elementary, my dear Watson.", attribution: "Sherlock Holmes")
  """
  @spec blockquote(Content.t() | [Content.t()] | String.t(), keyword()) :: Content.Quote.t()
  def blockquote(content, opts \\ []) when is_list(opts) do
    %Content.Quote{
      body: Content.to_content(content),
      block: Keyword.get(opts, :block, true),
      attribution: then_if_some(Keyword.get(opts, :attribution), &Content.to_content/1)
    }
  end

  # ── Helpers ──

  defp then_if_some(nil, _fun), do: nil
  defp then_if_some(val, fun), do: fun.(val)

  defp shape_body(opts) do
    case Keyword.get(opts, :body) do
      nil -> []
      body -> Content.to_content(body)
    end
  end
end
