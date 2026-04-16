defmodule Folio.DSL do
  @moduledoc """
  Builder functions for Folio content nodes.

  Every function returns a `%Folio.Content.*{}` struct.
  Use inside `#{}` interpolation in `~MD` sigils, or directly in Elixir code.

      use Folio
      content = [heading(1, "Title"), text("Hello"), strong("world")]
      {:ok, pdf} = Folio.to_pdf(content)
  """

  alias Folio.Content

  # ── Text ──

  @doc "Create a text node."
  @spec text(String.t()) :: Content.Text.t()
  def text(str), do: %Content.Text{text: str}

  # ── Headings ──

  @doc "Create a heading (levels 1-6)."
  @spec heading(1..6, Content.t() | [Content.t()] | String.t()) :: Content.Heading.t()
  def heading(level, content) when is_integer(level) and level >= 1 and level <= 6 do
    %Content.Heading{level: level, body: Content.to_content(content)}
  end

  @doc """
  Cite a bibliography entry.

      cite("knuth1984", form: "prose")
  """
  @spec cite(String.t(), keyword()) :: Content.Cite.t()
  def cite(key, opts \\ []) when is_binary(key) do
    %Content.Cite{
      key: key,
      supplement: then_if_some(Keyword.get(opts, :supplement), &Content.to_content/1),
      form: Keyword.get(opts, :form),
      style: Keyword.get(opts, :style)
    }
  end

  @doc """
  Insert a bibliography listing.

      bibliography("refs.bib", title: "References", style: "ieee")
  """
  @spec bibliography(String.t() | [String.t()], keyword()) :: Content.Bibliography.t()
  def bibliography(sources, opts \\ []) do
    normalized_sources =
      case sources do
        source when is_binary(source) -> [source]
        source_list when is_list(source_list) -> source_list
      end

    %Content.Bibliography{
      sources: normalized_sources,
      title: then_if_some(Keyword.get(opts, :title), &Content.to_content/1),
      full: Keyword.get(opts, :full, false),
      style: Keyword.get(opts, :style)
    }
  end

  # ── Inline formatting ──

  @doc "Bold text."
  @spec strong(Content.t() | [Content.t()] | String.t()) :: Content.Strong.t()
  def strong(content), do: %Content.Strong{body: Content.to_content(content)}

  @doc "Italic text."
  @spec emph(Content.t() | [Content.t()] | String.t()) :: Content.Emph.t()
  def emph(content), do: %Content.Emph{body: Content.to_content(content)}

  @doc "Strikethrough text."
  @spec strike(Content.t() | [Content.t()] | String.t()) :: Content.Strike.t()
  def strike(content), do: %Content.Strike{body: Content.to_content(content)}

  @doc "Underlined text."
  @spec underline(Content.t() | [Content.t()] | String.t()) :: Content.Underline.t()
  def underline(content), do: %Content.Underline{body: Content.to_content(content)}

  @doc "Highlighted text. Options: `:fill` color."
  @spec highlight(Content.t() | [Content.t()] | String.t(), keyword()) :: Content.Highlight.t()
  def highlight(content, opts \\ []) do
    %Content.Highlight{body: Content.to_content(content), fill: Keyword.get(opts, :fill)}
  end

  @doc "Superscript text."
  @spec superscript(Content.t() | [Content.t()] | String.t()) :: Content.Super.t()
  def superscript(content), do: %Content.Super{body: Content.to_content(content)}

  @doc "Subscript text."
  @spec subscript(Content.t() | [Content.t()] | String.t()) :: Content.Sub.t()
  def subscript(content), do: %Content.Sub{body: Content.to_content(content)}

  @doc "Small capitals text."
  @spec smallcaps(Content.t() | [Content.t()] | String.t()) :: Content.Smallcaps.t()
  def smallcaps(content), do: %Content.Smallcaps{body: Content.to_content(content)}

  # ── Images ──

  @doc """
  Embed an image. Options: `:width`, `:height`, `:fit` ("contain"/"cover"/"stretch").
  """
  @spec image(String.t(), keyword()) :: Content.Image.t()
  def image(src, opts \\ []) do
    %Content.Image{
      src: src,
      width: Keyword.get(opts, :width),
      height: Keyword.get(opts, :height),
      fit: Keyword.get(opts, :fit)
    }
  end

  # ── Figures ──

  @doc """
  Wrap content in a figure. Options: `:caption`, `:placement` ("top"/"bottom"), `:scope`, `:numbering`.
  """
  @spec figure(Content.t() | [Content.t()] | String.t(), keyword()) :: Content.Figure.t()
  def figure(content, opts \\ [])
      when is_binary(content) or is_struct(content) or is_list(content) do
    %Content.Figure{
      body: Content.to_content(content),
      caption: then_if_some(Keyword.get(opts, :caption), &Content.to_content/1),
      placement: Keyword.get(opts, :placement),
      scope: Keyword.get(opts, :scope),
      numbering: Keyword.get(opts, :numbering),
      separator: Keyword.get(opts, :separator)
    }
  end

  # ── Tables ──

  @doc "Create a table. Options: `:columns`, `:rows`, `:stroke`, `:gutter`, `:align`. Use `do` block for rows."
  @spec table(keyword(), [{:do, [Content.t()]}]) :: Content.Table.t()
  def table(opts, do: children) when is_list(opts) do
    %Content.Table{
      columns: Keyword.get(opts, :columns),
      rows: Keyword.get(opts, :rows),
      children: Content.flatten(Content.to_content(children)),
      stroke: Keyword.get(opts, :stroke),
      gutter: Keyword.get(opts, :gutter),
      align: Keyword.get(opts, :align)
    }
  end

  @doc "Create a table header row from a list of cell contents."
  @spec table_header([Content.t() | String.t()]) :: Content.TableHeader.t()
  def table_header(cells) when is_list(cells) do
    %Content.TableHeader{children: Enum.map(cells, &table_cell/1)}
  end

  @doc "Create a table data row from a list of cell contents."
  @spec table_row([Content.t() | String.t()]) :: Content.TableRow.t()
  def table_row(cells) when is_list(cells) do
    %Content.TableRow{children: Enum.map(cells, &table_cell/1)}
  end

  @doc "Create a table cell. Options: `:colspan`, `:rowspan`, `:align`."
  @spec table_cell(Content.t() | [Content.t()] | String.t(), keyword()) :: Content.TableCell.t()
  def table_cell(content, opts \\ []) do
    %Content.TableCell{
      body: Content.to_content(content),
      colspan: Keyword.get(opts, :colspan),
      rowspan: Keyword.get(opts, :rowspan),
      align: Keyword.get(opts, :align)
    }
  end

  # ── Layout ──

  @doc "Flow content into `count` columns. Options: `:gutter`."
  @spec columns(pos_integer(), keyword(), [{:do, [Content.t()]}]) :: Content.Columns.t()
  def columns(count, opts \\ [], do: body) when is_integer(count) and is_list(opts) do
    %Content.Columns{
      count: count,
      body: Content.flatten(Content.to_content(body)),
      gutter: Keyword.get(opts, :gutter)
    }
  end

  @doc "Force a column break. Options: `:weak`."
  @spec colbreak(keyword()) :: Content.Colbreak.t()
  def colbreak(opts \\ []), do: %Content.Colbreak{weak: Keyword.get(opts, :weak, false)}

  @doc "Force a page break. Options: `:weak`."
  @spec pagebreak(keyword()) :: Content.Pagebreak.t()
  def pagebreak(opts \\ []), do: %Content.Pagebreak{weak: Keyword.get(opts, :weak, false)}

  @doc "Insert a paragraph break."
  @spec parbreak() :: Content.Parbreak.t()
  def parbreak, do: %Content.Parbreak{}

  @doc "Insert a line break."
  @spec linebreak() :: Content.Linebreak.t()
  def linebreak, do: %Content.Linebreak{}

  @doc "Align content. Accepts `:left`, `:center`, `:right` or string equivalents."
  @spec align(atom() | String.t(), Content.t() | [Content.t()] | String.t()) :: Content.Align.t()
  def align(alignment, content)
      when alignment in [:left, :center, :right, "left", "center", "right"] do
    %Content.Align{alignment: to_string(alignment), body: Content.to_content(content)}
  end

  @doc "Block-level container. Options: `:width`, `:height`, `:above`, `:below`."
  @spec block(keyword(), [{:do, [Content.t()]}]) :: Content.Block.t()
  def block(opts \\ [], do: body) when is_list(opts) do
    %Content.Block{
      body: Content.flatten(Content.to_content(body)),
      width: Keyword.get(opts, :width),
      height: Keyword.get(opts, :height),
      above: Keyword.get(opts, :above),
      below: Keyword.get(opts, :below)
    }
  end

  @doc "Hide content (invisible but takes space)."
  @spec hide(Content.t() | [Content.t()] | String.t()) :: Content.Hide.t()
  def hide(content), do: %Content.Hide{body: Content.to_content(content)}

  @doc "Repeat content to fill available space."
  @spec repeat(Content.t() | [Content.t()] | String.t()) :: Content.Repeat.t()
  def repeat(content), do: %Content.Repeat{body: Content.to_content(content)}

  @doc "Place content at an alignment. Options: `:alignment`, `:float`."
  @spec place(Content.t() | [Content.t()] | String.t(), keyword()) :: Content.Place.t()
  def place(content, opts \\ []) do
    %Content.Place{
      alignment: Keyword.get(opts, :alignment),
      body: Content.to_content(content),
      float: Keyword.get(opts, :float)
    }
  end

  @doc "Vertical spacing. Options: `:weak`."
  @spec vspace(String.t() | number(), keyword()) :: Content.VSpace.t()
  def vspace(amount, opts \\ []) do
    %Content.VSpace{amount: to_string(amount), weak: Keyword.get(opts, :weak, false)}
  end

  @doc "Horizontal spacing. Options: `:weak`."
  @spec hspace(String.t() | number(), keyword()) :: Content.HSpace.t()
  def hspace(amount, opts \\ []) do
    %Content.HSpace{amount: to_string(amount), weak: Keyword.get(opts, :weak, false)}
  end

  @doc "Add padding around content. Options: `:left`, `:right`, `:top`, `:bottom`."
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

  @doc "Rectangle. Options: `:width`, `:height`, `:fill`, `:body`."
  @spec rect(keyword()) :: Content.Rect.t()
  def rect(opts \\ []) do
    %Content.Rect{
      body: shape_body(opts),
      width: Keyword.get(opts, :width),
      height: Keyword.get(opts, :height),
      fill: Keyword.get(opts, :fill)
    }
  end

  @doc "Square. Options: `:size`, `:fill`, `:body`."
  @spec square(keyword()) :: Content.Square.t()
  def square(opts \\ []) do
    %Content.Square{
      body: shape_body(opts),
      size: Keyword.get(opts, :size),
      fill: Keyword.get(opts, :fill)
    }
  end

  @doc "Circle. Options: `:radius`, `:fill`, `:body`."
  @spec circle(keyword()) :: Content.Circle.t()
  def circle(opts \\ []) do
    %Content.Circle{
      body: shape_body(opts),
      radius: Keyword.get(opts, :radius),
      fill: Keyword.get(opts, :fill)
    }
  end

  @doc "Ellipse. Options: `:width`, `:height`, `:fill`, `:body`."
  @spec ellipse(keyword()) :: Content.Ellipse.t()
  def ellipse(opts \\ []) do
    %Content.Ellipse{
      body: shape_body(opts),
      width: Keyword.get(opts, :width),
      height: Keyword.get(opts, :height),
      fill: Keyword.get(opts, :fill)
    }
  end

  @doc "Line. Options: `:start`, `:end`, `:length`, `:angle`, `:stroke`."
  @spec line(keyword()) :: Content.Line.t()
  def line(opts \\ []) do
    %Content.Line{
      start: Keyword.get(opts, :start),
      end: Keyword.get(opts, :end),
      length: Keyword.get(opts, :length),
      angle: Keyword.get(opts, :angle),
      stroke: Keyword.get(opts, :stroke)
    }
  end

  @doc "Polygon from coordinate list. Options: `:fill`, `:stroke`."
  @spec polygon([{number(), number()}], keyword()) :: Content.Polygon.t()
  def polygon(vertices, opts \\ []) do
    %Content.Polygon{
      vertices: Enum.map(vertices, &to_string/1),
      fill: Keyword.get(opts, :fill),
      stroke: Keyword.get(opts, :stroke)
    }
  end

  # ── Document structure ──

  @doc "Table of contents. Options: `:title`, `:indent`, `:depth`."
  @spec outline(keyword()) :: Content.Outline.t()
  def outline(opts \\ []) do
    %Content.Outline{
      title: Keyword.get(opts, :title),
      indent: Keyword.get(opts, :indent),
      depth: Keyword.get(opts, :depth)
    }
  end

  @doc "Document title."
  @spec title(Content.t() | [Content.t()] | String.t()) :: Content.Title.t()
  def title(content), do: %Content.Title{body: Content.to_content(content)}

  @doc "Horizontal divider."
  @spec divider() :: Content.Divider.t()
  def divider, do: %Content.Divider{}

  # ── Term lists ──

  @doc "Definition list from `{term, description}` tuples. Options: `:tight`."
  @spec term_list([{term(), term()}], keyword()) :: Content.TermList.t()
  def term_list(items, opts \\ []) when is_list(items) do
    children =
      Enum.map(items, fn {term, desc} ->
        %Content.TermItem{term: Content.to_content(term), description: Content.to_content(desc)}
      end)

    %Content.TermList{children: children, tight: Keyword.get(opts, :tight, true)}
  end

  @doc "Single term item."
  @spec term_item(term(), term()) :: Content.TermItem.t()
  def term_item(term, description) do
    %Content.TermItem{
      term: Content.to_content(term),
      description: Content.to_content(description)
    }
  end

  # ── Footnotes ──

  @doc "Footnote."
  @spec footnote(Content.t() | [Content.t()] | String.t()) :: Content.Footnote.t()
  def footnote(content), do: %Content.Footnote{body: Content.to_content(content)}

  # ── Lists ──

  @doc "Bullet list. Options: `:tight`, `:marker`."
  @spec list([term()], keyword()) :: Content.List.t()
  def list(items, opts \\ []) when is_list(items) do
    %Content.List{
      children: Enum.map(items, &%Content.ListItem{body: Content.to_content(&1)}),
      tight: Keyword.get(opts, :tight, true),
      marker: Keyword.get(opts, :marker)
    }
  end

  @doc """
  Numbered list. Items can be plain content or `{number, content}` tuples.

      enum(["First", "Second"])                    # auto-numbered
      enum([{1, "First"}, {5, "Fifth"}])           # explicit numbers
      enum(["A", "B"], start: 3)                   # start from 3
  """
  @spec enum([term()], keyword()) :: Content.EnumList.t()
  def enum(items, opts \\ []) when is_list(items) do
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

  # ── Links ──

  @doc "Hyperlink. Second argument is optional display text."
  @spec link(String.t(), nil | Content.t() | String.t()) :: Content.Link.t()
  def link(url, text \\ nil) do
    %Content.Link{url: url, body: if(text, do: Content.to_content(text), else: [])}
  end

  # ── Labels & References ──

  @doc "Label a position for cross-references."
  @spec label(String.t()) :: Content.Label.t()
  def label(name) when is_binary(name), do: %Content.Label{name: name}

  @doc "Reference a labelled element."
  @spec ref(String.t(), nil | Content.t() | [Content.t()] | String.t()) :: Content.Ref.t()
  def ref(target, supplement \\ nil) do
    %Content.Ref{target: target, supplement: if(supplement, do: Content.to_content(supplement))}
  end

  # ── Math ──

  @doc "Math expression in Typst syntax. Options: `:block`."
  @spec math(String.t(), keyword()) :: Content.Math.t()
  def math(content, opts \\ []) do
    %Content.Math{content: content, block: Keyword.get(opts, :block, false)}
  end

  # ── Raw / Code ──

  @doc "Raw/code text. Options: `:lang`, `:block`."
  @spec raw(String.t(), keyword()) :: Content.Raw.t()
  def raw(text, opts \\ []) do
    %Content.Raw{
      text: text,
      lang: Keyword.get(opts, :lang),
      block: Keyword.get(opts, :block, true)
    }
  end

  # ── Quote ──

  @doc "Block quote. Options: `:block`, `:attribution`."
  @spec blockquote(Content.t() | [Content.t()] | String.t(), keyword()) :: Content.Quote.t()
  def blockquote(content, opts \\ []) do
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
