defmodule Folio.DSL do
  @moduledoc """
  Builder functions for Folio content nodes.

  Every function returns a `%Folio.Content.*{}` struct.
  These are used inside `#{}` interpolation in `~MD` sigils,
  or directly in Elixir code building documents programmatically.
  """

  alias Folio.{Content, Value}

  # --- Text ---

  @doc "Plain text node."
  def text(str) when is_binary(str), do: %Content.Text{text: str}

  @doc "Styled text. Maps to `#text(...)[...]`."
  def text(str, opts) when is_binary(str) and is_list(opts) do
    %Content.Paragraph{
      body: [
        %Content.Text{text: str}
      ]
    }
  end

  # --- Headings ---

  @doc "Create a heading. Level 1-6."
  def heading(level, content) when is_integer(level) and level >= 1 and level <= 6 do
    %Content.Heading{level: level, body: Content.to_content(content)}
  end

  # --- Emphasis ---

  @doc "Bold/strong content."
  def strong(content), do: %Content.Strong{body: Content.to_content(content)}

  @doc "Italic/emphasized content."
  def emph(content), do: %Content.Emph{body: Content.to_content(content)}

  # --- Images ---

  @doc "Insert an image."
  def image(src, opts \\ []) do
    %Content.Image{
      src: src,
      width: Keyword.get(opts, :width),
      height: Keyword.get(opts, :height),
      fit: Keyword.get(opts, :fit)
    }
  end

  # --- Figures ---

  @doc "Wrap content in a figure with optional caption."
  def figure(opts \\ [], do: body) when is_list(opts) do
    caption = Keyword.get(opts, :caption)
    %Content.Figure{
      body: Content.flatten(Content.to_content(body)),
      caption: if(caption, do: Content.to_content(caption)),
      placement: Keyword.get(opts, :placement),
      scope: Keyword.get(opts, :scope),
      numbering: Keyword.get(opts, :numbering),
      separator: Keyword.get(opts, :separator)
    }
  end

  def figure(content, opts) when (is_binary(content) or is_struct(content)) and is_list(opts) do
    %Content.Figure{
      body: Content.to_content(content),
      caption: Keyword.get(opts, :caption) |> then_if_some(&Content.to_content/1),
      placement: Keyword.get(opts, :placement)
    }
  end

  # --- Tables ---

  @doc "Create a table with columns and children."
  def table(opts, do: children) when is_list(opts) do
    %Content.Table{
      columns: Keyword.get(opts, :columns, [:auto]),
      rows: Keyword.get(opts, :rows),
      children: Content.flatten(Content.to_content(children)),
      stroke: Keyword.get(opts, :stroke),
      gutter: Keyword.get(opts, :gutter),
      align: Keyword.get(opts, :align)
    }
  end

  @doc "Create a table header row."
  def table_header(cells) when is_list(cells) do
    %Content.TableHeader{
      children: Enum.map(cells, &table_cell/1)
    }
  end

  @doc "Create a table row."
  def table_row(cells) when is_list(cells) do
    %Content.TableRow{
      children: Enum.map(cells, &table_cell/1)
    }
  end

  @doc "Create a table cell."
  def table_cell(content, opts \\ []) do
    %Content.TableCell{
      body: Content.to_content(content),
      colspan: Keyword.get(opts, :colspan),
      rowspan: Keyword.get(opts, :rowspan),
      align: Keyword.get(opts, :align)
    }
  end

  # --- Layout ---

  @doc "Multi-column layout."
  def columns(count, opts \\ [], do: body) when is_integer(count) and is_list(opts) do
    %Content.Columns{
      count: count,
      body: Content.flatten(Content.to_content(body)),
      gutter: Keyword.get(opts, :gutter)
    }
  end

  @doc "Insert a page break."
  def pagebreak(opts \\ []), do: %Content.Pagebreak{weak: Keyword.get(opts, :weak, false)}

  @doc "Insert a paragraph break."
  def parbreak, do: %Content.Parbreak{}

  @doc "Insert a line break."
  def linebreak, do: %Content.Linebreak{}

  @doc "Align content."
  def align(alignment, content) when alignment in [:left, :center, :right] do
    %Content.Align{alignment: alignment, body: Content.to_content(content)}
  end

  @doc "Block container with spacing."
  def block(opts \\ [], do: body) when is_list(opts) do
    %Content.Block{
      body: Content.flatten(Content.to_content(body)),
      width: Keyword.get(opts, :width),
      height: Keyword.get(opts, :height),
      above: Keyword.get(opts, :above),
      below: Keyword.get(opts, :below)
    }
  end

  @doc "Pad content."
  def pad(opts, do: body) when is_list(opts) do
    %Content.Pad{
      body: Content.flatten(Content.to_content(body)),
      left: Keyword.get(opts, :left),
      right: Keyword.get(opts, :right),
      top: Keyword.get(opts, :top),
      bottom: Keyword.get(opts, :bottom),
      x: Keyword.get(opts, :x),
      y: Keyword.get(opts, :y),
      rest: Keyword.get(opts, :rest)
    }
  end

  # --- Lists ---

  @doc "Bullet list."
  def list(items, opts \\ []) when is_list(items) do
    %Content.List{
      children: Enum.map(items, &%Content.ListItem{body: Content.to_content(&1)}),
      tight: Keyword.get(opts, :tight, true),
      marker: Keyword.get(opts, :marker)
    }
  end

  @doc "Numbered list."
  def enum(items, opts \\ []) when is_list(items) do
    %Content.Enum{
      children:
        Enum.map(items, fn
          {num, content} ->
            %Content.EnumItem{body: Content.to_content(content), number: num}

          content ->
            %Content.EnumItem{body: Content.to_content(content), number: nil}
        end),
      tight: Keyword.get(opts, :tight, true),
      start: Keyword.get(opts, :start)
    }
  end

  # --- Links ---

  @doc "Create a hyperlink."
  def link(url, text \\ nil) do
    %Content.Link{url: url, body: if(text, do: Content.to_content(text), else: [])}
  end

  # --- Labels & References ---

  @doc "Attach a label for referencing."
  def label(name) when is_binary(name), do: %Content.Label{name: name}

  @doc "Reference a label."
  def ref(target, supplement \\ nil) do
    %Content.Ref{
      target: target,
      supplement: if(supplement, do: Content.to_content(supplement))
    }
  end

  # --- Math ---

  @doc "Inline or block math expression (Typst math syntax)."
  def math(content, opts \\ []) do
    %Content.Math{
      content: content,
      block: Keyword.get(opts, :block, false)
    }
  end

  # --- Raw / Code ---

  @doc "Raw text / code block."
  def raw(text, opts \\ []) do
    %Content.Raw{
      text: text,
      lang: Keyword.get(opts, :lang),
      block: Keyword.get(opts, :block, true)
    }
  end

  # --- Quote ---

  @doc "Block or inline quote."
  def quote(content, opts \\ []) do
    %Content.Quote{
      body: Content.to_content(content),
      block: Keyword.get(opts, :block, true),
      attribution: Keyword.get(opts, :attribution) |> then_if_some(&Content.to_content/1)
    }
  end

  # --- Bibliography ---

  @doc "Insert bibliography."
  def bibliography(source, opts \\ []) do
    %Content.Bibliography{
      source: source,
      style: Keyword.get(opts, :style),
      full: Keyword.get(opts, :full)
    }
  end

  # --- Grid ---

  @doc "Grid layout."
  def grid(opts, do: children) when is_list(opts) do
    %Content.Grid{
      columns: Keyword.get(opts, :columns, [:auto]),
      rows: Keyword.get(opts, :rows),
      children: Content.flatten(Content.to_content(children)),
      gutter: Keyword.get(opts, :gutter),
      stroke: Keyword.get(opts, :stroke),
      align: Keyword.get(opts, :align)
    }
  end

  # --- Helpers ---

  defp then_if_some(nil, _fun), do: nil
  defp then_if_some(val, fun), do: fun.(val)
end
