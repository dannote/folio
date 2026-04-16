defmodule Folio.DSL do
  @moduledoc """
  Builder functions for Folio content nodes.

  Every function returns a `%Folio.Content.*{}` struct.
  Use inside `#{}` interpolation in `~MD` sigils, or in Elixir code.
  """

  alias Folio.Content

  # ── Text ──

  def text(str), do: %Content.Text{text: str}

  # ── Headings ──

  def heading(level, content) when is_integer(level) and level >= 1 and level <= 6 do
    %Content.Heading{level: level, body: Content.to_content(content)}
  end

  # ── Inline formatting ──

  def strong(content), do: %Content.Strong{body: Content.to_content(content)}
  def emph(content), do: %Content.Emph{body: Content.to_content(content)}
  def strike(content), do: %Content.Strike{body: Content.to_content(content)}
  def underline(content), do: %Content.Underline{body: Content.to_content(content)}
  def highlight(content, opts \\ []) do
    %Content.Highlight{body: Content.to_content(content), fill: Keyword.get(opts, :fill)}
  end
  def superscript(content), do: %Content.Super{body: Content.to_content(content)}
  def subscript(content), do: %Content.Sub{body: Content.to_content(content)}
  def smallcaps(content), do: %Content.Smallcaps{body: Content.to_content(content)}

  # ── Images ──

  def image(src, opts \\ []) do
    %Content.Image{
      src: src,
      width: Keyword.get(opts, :width),
      height: Keyword.get(opts, :height),
      fit: Keyword.get(opts, :fit),
    }
  end

  # ── Figures ──

  def figure(content, opts \\ []) when is_binary(content) or is_struct(content) or is_list(content) do
    %Content.Figure{
      body: Content.to_content(content),
      caption: then_if_some(Keyword.get(opts, :caption), &Content.to_content/1),
      placement: Keyword.get(opts, :placement),
      scope: Keyword.get(opts, :scope),
      numbering: Keyword.get(opts, :numbering),
      separator: Keyword.get(opts, :separator),
    }
  end

  # ── Tables ──

  def table(opts, do: children) when is_list(opts) do
    %Content.Table{
      columns: Keyword.get(opts, :columns),
      rows: Keyword.get(opts, :rows),
      children: Content.flatten(Content.to_content(children)),
      stroke: Keyword.get(opts, :stroke),
      gutter: Keyword.get(opts, :gutter),
      align: Keyword.get(opts, :align),
    }
  end

  def table_header(cells) when is_list(cells) do
    %Content.TableHeader{children: Enum.map(cells, &table_cell/1)}
  end

  def table_row(cells) when is_list(cells) do
    %Content.TableRow{children: Enum.map(cells, &table_cell/1)}
  end

  def table_cell(content, opts \\ []) do
    %Content.TableCell{
      body: Content.to_content(content),
      colspan: Keyword.get(opts, :colspan),
      rowspan: Keyword.get(opts, :rowspan),
      align: Keyword.get(opts, :align),
    }
  end

  # ── Layout ──

  def columns(count, opts \\ [], do: body) when is_integer(count) and is_list(opts) do
    %Content.Columns{
      count: count,
      body: Content.flatten(Content.to_content(body)),
      gutter: Keyword.get(opts, :gutter),
    }
  end

  def colbreak(opts \\ []), do: %Content.Colbreak{weak: Keyword.get(opts, :weak, false)}
  def pagebreak(opts \\ []), do: %Content.Pagebreak{weak: Keyword.get(opts, :weak, false)}
  def parbreak, do: %Content.Parbreak{}
  def linebreak, do: %Content.Linebreak{}

  def align(alignment, content) when alignment in [:left, :center, :right, "left", "center", "right"] do
    %Content.Align{alignment: to_string(alignment), body: Content.to_content(content)}
  end

  def block(opts \\ [], do: body) when is_list(opts) do
    %Content.Block{
      body: Content.flatten(Content.to_content(body)),
      width: Keyword.get(opts, :width),
      height: Keyword.get(opts, :height),
      above: Keyword.get(opts, :above),
      below: Keyword.get(opts, :below),
    }
  end

  def hide(content), do: %Content.Hide{body: Content.to_content(content)}

  def repeat(content), do: %Content.Repeat{body: Content.to_content(content)}

  def place(content, opts \\ []) do
    %Content.Place{
      alignment: Keyword.get(opts, :alignment),
      body: Content.to_content(content),
      float: Keyword.get(opts, :float),
    }
  end

  def vspace(amount, opts \\ []) do
    %Content.VSpace{amount: to_string(amount), weak: Keyword.get(opts, :weak, false)}
  end

  def hspace(amount, opts \\ []) do
    %Content.HSpace{amount: to_string(amount), weak: Keyword.get(opts, :weak, false)}
  end

  def pad(opts, do: body) when is_list(opts) do
    %Content.Pad{
      body: Content.flatten(Content.to_content(body)),
      left: Keyword.get(opts, :left),
      right: Keyword.get(opts, :right),
      top: Keyword.get(opts, :top),
      bottom: Keyword.get(opts, :bottom),
    }
  end

  def stack(opts, do: children) when is_list(opts) do
    %Content.Stack{
      dir: Keyword.get(opts, :dir, "ttb"),
      children: Content.flatten(Content.to_content(children)),
      spacing: Keyword.get(opts, :spacing),
    }
  end

  # ── Shapes ──

  def rect(opts \\ []) do
    body = Keyword.get(opts, :body)
    %Content.Rect{
      body: if(body, do: Content.to_content(body), else: []),
      width: Keyword.get(opts, :width),
      height: Keyword.get(opts, :height),
      fill: Keyword.get(opts, :fill),
      stroke: Keyword.get(opts, :stroke),
      inset: Keyword.get(opts, :inset),
      outset: Keyword.get(opts, :outset),
    }
  end

  def square(opts \\ []) do
    body = Keyword.get(opts, :body)
    %Content.Square{
      body: if(body, do: Content.to_content(body), else: []),
      size: Keyword.get(opts, :size),
      fill: Keyword.get(opts, :fill),
      stroke: Keyword.get(opts, :stroke),
      inset: Keyword.get(opts, :inset),
      outset: Keyword.get(opts, :outset),
    }
  end

  def circle(opts \\ []) do
    body = Keyword.get(opts, :body)
    %Content.Circle{
      body: if(body, do: Content.to_content(body), else: []),
      radius: Keyword.get(opts, :radius),
      fill: Keyword.get(opts, :fill),
      stroke: Keyword.get(opts, :stroke),
      inset: Keyword.get(opts, :inset),
      outset: Keyword.get(opts, :outset),
    }
  end

  def ellipse(opts \\ []) do
    body = Keyword.get(opts, :body)
    %Content.Ellipse{
      body: if(body, do: Content.to_content(body), else: []),
      width: Keyword.get(opts, :width),
      height: Keyword.get(opts, :height),
      fill: Keyword.get(opts, :fill),
      stroke: Keyword.get(opts, :stroke),
      inset: Keyword.get(opts, :inset),
      outset: Keyword.get(opts, :outset),
    }
  end

  def line(opts \\ []) do
    %Content.Line{
      start: Keyword.get(opts, :start),
      end: Keyword.get(opts, :end),
      length: Keyword.get(opts, :length),
      angle: Keyword.get(opts, :angle),
      stroke: Keyword.get(opts, :stroke),
    }
  end

  def polygon(vertices, opts \\ []) do
    %Content.Polygon{
      vertices: Enum.map(vertices, &to_string/1),
      fill: Keyword.get(opts, :fill),
      stroke: Keyword.get(opts, :stroke),
    }
  end

  # ── Document structure ──

  def outline(opts \\ []) do
    %Content.Outline{
      title: Keyword.get(opts, :title),
      indent: Keyword.get(opts, :indent),
      depth: Keyword.get(opts, :depth),
    }
  end

  def title(content), do: %Content.Title{body: Content.to_content(content)}

  def divider, do: %Content.Divider{}

  # ── Term lists ──

  def term_list(items, opts \\ []) when is_list(items) do
    children = Enum.map(items, fn {term, desc} ->
      %Content.TermItem{term: Content.to_content(term), description: Content.to_content(desc)}
    end)
    %Content.TermList{children: children, tight: Keyword.get(opts, :tight, true)}
  end

  def term_item(term, description) do
    %Content.TermItem{term: Content.to_content(term), description: Content.to_content(description)}
  end

  # ── Footnotes ──

  def footnote(content), do: %Content.Footnote{body: Content.to_content(content)}

  # ── Lists ──

  def list(items, opts \\ []) when is_list(items) do
    %Content.List{
      children: Enum.map(items, &%Content.ListItem{body: Content.to_content(&1)}),
      tight: Keyword.get(opts, :tight, true),
      marker: Keyword.get(opts, :marker),
    }
  end

  def enum(items, opts \\ []) when is_list(items) do
    %Content.Enum{
      children: Enum.map(items, fn
        {num, content} -> %Content.EnumItem{body: Content.to_content(content), number: num}
        content -> %Content.EnumItem{body: Content.to_content(content), number: nil}
      end),
      tight: Keyword.get(opts, :tight, true),
      start: Keyword.get(opts, :start),
    }
  end

  # ── Links ──

  def link(url, text \\ nil) do
    %Content.Link{url: url, body: if(text, do: Content.to_content(text), else: [])}
  end

  # ── Labels & References ──

  def label(name) when is_binary(name), do: %Content.Label{name: name}

  def ref(target, supplement \\ nil) do
    %Content.Ref{target: target, supplement: if(supplement, do: Content.to_content(supplement))}
  end

  # ── Math ──

  def math(content, opts \\ []) do
    %Content.Math{content: content, block: Keyword.get(opts, :block, false)}
  end

  # ── Raw / Code ──

  def raw(text, opts \\ []) do
    %Content.Raw{text: text, lang: Keyword.get(opts, :lang), block: Keyword.get(opts, :block, true)}
  end

  # ── Quote ──

  def blockquote(content, opts \\ []) do
    %Content.Quote{
      body: Content.to_content(content),
      block: Keyword.get(opts, :block, true),
      attribution: then_if_some(Keyword.get(opts, :attribution), &Content.to_content/1),
    }
  end

  # ── Helpers ──

  defp then_if_some(nil, _fun), do: nil
  defp then_if_some(val, fun), do: fun.(val)
end
