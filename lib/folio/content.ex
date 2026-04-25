defmodule Folio.Content do
  @moduledoc """
  Typed content nodes that map 1:1 to Typst elements.

  Every struct has matching fields in `native/folio_nif/src/types.rs`.
  The Rust NifStruct `#[module = "Folio.Content.*"]` must match exactly.
  """

  defmodule Text do
    @moduledoc "A plain text run. Fields: `text`, `size`, `weight`, `fill`, `tracking`."
    defstruct [:text, :size, :weight, :fill, :tracking]

    @type t :: %__MODULE__{
            text: String.t(),
            size: String.t() | nil,
            weight: String.t() | nil,
            fill: String.t() | nil,
            tracking: String.t() | nil
          }
  end

  defmodule Space do
    @moduledoc "Inter-word space."
    defstruct []
    @type t :: %__MODULE__{}
  end

  defmodule Heading do
    @moduledoc "A section heading. Fields: `body`, `level` (1-6)."
    defstruct [:body, :level]
    @type t :: %__MODULE__{body: [Folio.Content.t()], level: 1..6}
  end

  defmodule Cite do
    @moduledoc "A citation from a bibliography. Fields: `key`, `supplement`, `form`, `style`."
    defstruct [:key, :supplement, :form, :style]

    @type t :: %__MODULE__{
            key: String.t(),
            supplement: [Folio.Content.t()] | nil,
            form: String.t() | nil,
            style: String.t() | nil
          }
  end

  defmodule Bibliography do
    @moduledoc "A bibliography listing. Fields: `sources`, `title`, `full`, `style`."
    defstruct [:sources, :title, :full, :style]

    @type t :: %__MODULE__{
            sources: [String.t()],
            title: [Folio.Content.t()] | nil,
            full: boolean(),
            style: String.t() | nil
          }
  end

  defmodule Paragraph do
    @moduledoc "A body paragraph. Field: `body`."
    defstruct [:body]
    @type t :: %__MODULE__{body: [Folio.Content.t()]}
  end

  defmodule Strong do
    @moduledoc "Bold text."
    defstruct [:body]
    @type t :: %__MODULE__{body: [Folio.Content.t()]}
  end

  defmodule Emph do
    @moduledoc "Italic text."
    defstruct [:body]
    @type t :: %__MODULE__{body: [Folio.Content.t()]}
  end

  defmodule Strike do
    @moduledoc "Strikethrough text."
    defstruct [:body]
    @type t :: %__MODULE__{body: [Folio.Content.t()]}
  end

  defmodule Underline do
    @moduledoc "Underlined text."
    defstruct [:body]
    @type t :: %__MODULE__{body: [Folio.Content.t()]}
  end

  defmodule Highlight do
    @moduledoc "Highlighted text."
    defstruct [:body, :fill]
    @type t :: %__MODULE__{body: [Folio.Content.t()], fill: String.t() | nil}
  end

  defmodule Super do
    @moduledoc "Superscript text."
    defstruct [:body]
    @type t :: %__MODULE__{body: [Folio.Content.t()]}
  end

  defmodule Sub do
    @moduledoc "Subscript text."
    defstruct [:body]
    @type t :: %__MODULE__{body: [Folio.Content.t()]}
  end

  defmodule Smallcaps do
    @moduledoc "Small capitals text."
    defstruct [:body]
    @type t :: %__MODULE__{body: [Folio.Content.t()]}
  end

  defmodule Image do
    @moduledoc "An image. Fields: `src`, `width`, `height`, `fit`."
    defstruct [:src, :width, :height, :fit]

    @type t :: %__MODULE__{
            src: String.t(),
            width: String.t() | nil,
            height: String.t() | nil,
            fit: String.t() | nil
          }
  end

  defmodule Figure do
    @moduledoc "A figure with optional caption. Fields: `body`, `caption`, `placement`, `numbering`."
    defstruct [:body, :caption, :placement, :scope, :numbering, :separator]

    @type t :: %__MODULE__{
            body: [Folio.Content.t()],
            caption: [Folio.Content.t()] | nil,
            placement: String.t() | nil,
            scope: String.t() | nil,
            numbering: String.t() | nil,
            separator: String.t() | nil
          }
  end

  defmodule Table do
    @moduledoc "A table grid. Fields: `children`, `gutter`, `stroke`, `align`, `inset`, `fill`."
    defstruct [:columns, :rows, :children, :stroke, :gutter, :align, :inset, :fill]

    @type t :: %__MODULE__{
            columns: [String.t()] | nil,
            rows: String.t() | nil,
            children: [Folio.Content.t()],
            stroke: String.t() | nil,
            gutter: String.t() | nil,
            align: String.t() | nil,
            inset: String.t() | nil,
            fill: String.t() | nil
          }
  end

  defmodule TableHeader do
    @moduledoc "Table header row."
    defstruct [:children]
    @type t :: %__MODULE__{children: [Folio.Content.t()]}
  end

  defmodule TableRow do
    @moduledoc "Table data row."
    defstruct [:children]
    @type t :: %__MODULE__{children: [Folio.Content.t()]}
  end

  defmodule TableCell do
    @moduledoc "Table cell."
    defstruct [:body, :colspan, :rowspan, :align, :fill, :stroke]

    @type t :: %__MODULE__{
            body: [Folio.Content.t()],
            colspan: pos_integer() | nil,
            rowspan: pos_integer() | nil,
            align: String.t() | nil,
            fill: String.t() | nil,
            stroke: String.t() | nil
          }
  end

  defmodule Columns do
    @moduledoc "Multi-column layout."
    defstruct [:count, :body, :gutter]

    @type t :: %__MODULE__{
            count: pos_integer(),
            body: [Folio.Content.t()],
            gutter: String.t() | nil
          }
  end

  defmodule Colbreak do
    @moduledoc "Column break."
    defstruct [:weak]
    @type t :: %__MODULE__{weak: boolean()}
  end

  defmodule Pagebreak do
    @moduledoc "Page break."
    defstruct [:weak]
    @type t :: %__MODULE__{weak: boolean()}
  end

  defmodule Parbreak do
    @moduledoc "Paragraph break."
    defstruct []
    @type t :: %__MODULE__{}
  end

  defmodule Linebreak do
    @moduledoc "Line break."
    defstruct []
    @type t :: %__MODULE__{}
  end

  defmodule Math do
    @moduledoc "Math expression."
    defstruct [:content, :block]
    @type t :: %__MODULE__{content: String.t(), block: boolean()}
  end

  defmodule Link do
    @moduledoc "Hyperlink."
    defstruct [:url, :body]
    @type t :: %__MODULE__{url: String.t(), body: [Folio.Content.t()]}
  end

  defmodule Raw do
    @moduledoc "Raw/code text."
    defstruct [:text, :lang, :block]
    @type t :: %__MODULE__{text: String.t(), lang: String.t() | nil, block: boolean()}
  end

  defmodule Quote do
    @moduledoc "Block quote."
    defstruct [:body, :block, :attribution]

    @type t :: %__MODULE__{
            body: [Folio.Content.t()],
            block: boolean(),
            attribution: [Folio.Content.t()] | nil
          }
  end

  defmodule List do
    @moduledoc "Bullet list."
    defstruct [:children, :tight, :marker]

    @type t :: %__MODULE__{
            children: [Folio.Content.t()],
            tight: boolean(),
            marker: String.t() | nil
          }
  end

  defmodule ListItem do
    @moduledoc "Bullet list item."
    defstruct [:body]
    @type t :: %__MODULE__{body: [Folio.Content.t()]}
  end

  defmodule EnumList do
    @moduledoc "Numbered (ordered) list."
    defstruct [:children, :tight, :start]

    @type t :: %__MODULE__{
            children: [Folio.Content.t()],
            tight: boolean(),
            start: pos_integer() | nil
          }
  end

  defmodule EnumItem do
    @moduledoc "Numbered list item."
    defstruct [:body, :number]
    @type t :: %__MODULE__{body: [Folio.Content.t()], number: pos_integer() | nil}
  end

  defmodule Label do
    @moduledoc "Cross-reference label."
    defstruct [:name]
    @type t :: %__MODULE__{name: String.t()}
  end

  defmodule Ref do
    @moduledoc "Cross-reference."
    defstruct [:target, :supplement]
    @type t :: %__MODULE__{target: String.t(), supplement: [Folio.Content.t()] | nil}
  end

  defmodule Align do
    @moduledoc "Content alignment."
    defstruct [:alignment, :body]
    @type t :: %__MODULE__{alignment: String.t(), body: [Folio.Content.t()]}
  end

  defmodule Block do
    @moduledoc "Block-level container."
    defstruct [:body, :width, :height, :above, :below, :fill, :inset, :radius, :stroke]

    @type t :: %__MODULE__{
            body: [Folio.Content.t()],
            width: String.t() | nil,
            height: String.t() | nil,
            above: String.t() | nil,
            below: String.t() | nil,
            fill: String.t() | nil,
            inset: String.t() | nil,
            radius: String.t() | nil,
            stroke: String.t() | nil
          }
  end

  defmodule Hide do
    @moduledoc "Hidden content."
    defstruct [:body]
    @type t :: %__MODULE__{body: [Folio.Content.t()]}
  end

  defmodule Repeat do
    @moduledoc "Repeating content."
    defstruct [:body]
    @type t :: %__MODULE__{body: [Folio.Content.t()]}
  end

  defmodule Place do
    @moduledoc "Absolute placement."
    defstruct [:alignment, :body, :float]

    @type t :: %__MODULE__{
            alignment: String.t() | nil,
            body: [Folio.Content.t()],
            float: boolean() | nil
          }
  end

  defmodule VSpace do
    @moduledoc "Vertical spacing."
    defstruct [:amount, :weak]
    @type t :: %__MODULE__{amount: String.t(), weak: boolean()}
  end

  defmodule HSpace do
    @moduledoc "Horizontal spacing."
    defstruct [:amount, :weak]
    @type t :: %__MODULE__{amount: String.t(), weak: boolean()}
  end

  defmodule Pad do
    @moduledoc "Padding around content."
    defstruct [:body, :left, :right, :top, :bottom]

    @type t :: %__MODULE__{
            body: [Folio.Content.t()],
            left: String.t() | nil,
            right: String.t() | nil,
            top: String.t() | nil,
            bottom: String.t() | nil
          }
  end

  defmodule Stack do
    @moduledoc "Stacked layout."
    defstruct [:dir, :children, :spacing]

    @type t :: %__MODULE__{
            dir: String.t(),
            children: [Folio.Content.t()],
            spacing: String.t() | nil
          }
  end

  defmodule Rect do
    @moduledoc "Rectangle shape."
    defstruct [:body, :width, :height, :fill, :inset, :radius]

    @type t :: %__MODULE__{
            body: [Folio.Content.t()],
            width: String.t() | nil,
            height: String.t() | nil,
            fill: String.t() | nil,
            inset: String.t() | nil,
            radius: String.t() | nil
          }
  end

  defmodule Square do
    @moduledoc "Square shape."
    defstruct [:body, :size, :fill]

    @type t :: %__MODULE__{
            body: [Folio.Content.t()],
            size: String.t() | nil,
            fill: String.t() | nil
          }
  end

  defmodule Circle do
    @moduledoc "Circle shape."
    defstruct [:body, :radius, :fill]

    @type t :: %__MODULE__{
            body: [Folio.Content.t()],
            radius: String.t() | nil,
            fill: String.t() | nil
          }
  end

  defmodule Ellipse do
    @moduledoc "Ellipse shape."
    defstruct [:body, :width, :height, :fill]

    @type t :: %__MODULE__{
            body: [Folio.Content.t()],
            width: String.t() | nil,
            height: String.t() | nil,
            fill: String.t() | nil
          }
  end

  defmodule Line do
    @moduledoc "Line shape."
    defstruct [:start, :end, :length, :angle, :stroke]

    @type t :: %__MODULE__{
            start: String.t() | nil,
            end: String.t() | nil,
            length: String.t() | nil,
            angle: String.t() | nil,
            stroke: String.t() | nil
          }
  end

  defmodule Polygon do
    @moduledoc "Polygon shape."
    defstruct [:vertices, :fill, :stroke]

    @type t :: %__MODULE__{
            vertices: [String.t()],
            fill: String.t() | nil,
            stroke: String.t() | nil
          }
  end

  defmodule Outline do
    @moduledoc "Table of contents."
    defstruct [:title, :indent, :depth]

    @type t :: %__MODULE__{
            title: String.t() | nil,
            indent: String.t() | nil,
            depth: pos_integer() | nil
          }
  end

  defmodule Title do
    @moduledoc "Document title."
    defstruct [:body]
    @type t :: %__MODULE__{body: [Folio.Content.t()]}
  end

  defmodule TermList do
    @moduledoc "Definition/term list."
    defstruct [:children, :tight]
    @type t :: %__MODULE__{children: [Folio.Content.t()], tight: boolean()}
  end

  defmodule TermItem do
    @moduledoc "Term list item."
    defstruct [:term, :description]
    @type t :: %__MODULE__{term: [Folio.Content.t()], description: [Folio.Content.t()]}
  end

  defmodule Footnote do
    @moduledoc "Footnote."
    defstruct [:body]
    @type t :: %__MODULE__{body: [Folio.Content.t()]}
  end

  defmodule Divider do
    @moduledoc "Horizontal divider."
    defstruct []
    @type t :: %__MODULE__{}
  end

  defmodule Grid do
    @moduledoc "Grid layout. Fields: `columns`, `rows`, `gutter`, `column_gutter`, `row_gutter`, `children`."
    defstruct [:columns, :rows, :gutter, :column_gutter, :row_gutter, :children]

    @type t :: %__MODULE__{
            columns: [String.t()] | pos_integer() | nil,
            rows: [String.t()] | nil,
            gutter: String.t() | nil,
            column_gutter: String.t() | nil,
            row_gutter: String.t() | nil,
            children: [Folio.Content.t()]
          }
  end

  defmodule GridCell do
    @moduledoc "Grid cell. Fields: `body`, `colspan`, `rowspan`, `align`, `fill`."
    defstruct [:body, :colspan, :rowspan, :align, :fill]

    @type t :: %__MODULE__{
            body: [Folio.Content.t()],
            colspan: pos_integer() | nil,
            rowspan: pos_integer() | nil,
            align: String.t() | nil,
            fill: String.t() | nil
          }
  end

  defmodule LocalSet do
    @moduledoc """
    Local style overrides for a content block.
    Mirrors Typst's `#set text(...)` within a scope.

    Fields:
    - `body` — child content
    - `hyphenate` — override text hyphenation for this block
    - `justify` — override paragraph justification
    - `first_line_indent` — override first-line indent (nil = no change)
    """
    defstruct [:body, :hyphenate, :justify, :first_line_indent]

    @type t :: %__MODULE__{
            body: [Folio.Content.t()],
            hyphenate: boolean() | nil,
            justify: boolean() | nil,
            first_line_indent: float() | nil
          }
  end

  defmodule RawTypst do
    @moduledoc """
    Raw Typst source injected directly into the document.
    Use when Folio's abstraction isn't enough.

    Field: `source` — Typst markup/code string.
    """
    defstruct [:source]

    @type t :: %__MODULE__{source: String.t()}
  end

  defmodule ShowRule do
    @moduledoc """
    A show rule that transforms matching content elements before compilation.

    Applied on the Elixir side; never sent to Rust. The transform function
    receives the matched struct and returns replacement content.

    Targets are atoms matching content types: `:enum`, `:enum_item`, `:list`,
    `:list_item`, `:heading`, `:paragraph`, `:quote`, `:table`, `:grid`,
    `:block`, etc.
    """
    defstruct [:target, :transform]

    @type t :: %__MODULE__{
            target: atom(),
            transform: (struct() -> Folio.Content.t() | [Folio.Content.t()] | String.t())
          }
  end

  defmodule Sequence do
    @moduledoc "Content sequence."
    defstruct [:children]
    @type t :: %__MODULE__{children: [Folio.Content.t()]}
  end

  @type t ::
          Text.t()
          | Space.t()
          | Heading.t()
          | Cite.t()
          | Bibliography.t()
          | Paragraph.t()
          | Strong.t()
          | Emph.t()
          | Strike.t()
          | Underline.t()
          | Highlight.t()
          | Super.t()
          | Sub.t()
          | Smallcaps.t()
          | Image.t()
          | Figure.t()
          | Table.t()
          | TableHeader.t()
          | TableRow.t()
          | TableCell.t()
          | Columns.t()
          | Colbreak.t()
          | Pagebreak.t()
          | Parbreak.t()
          | Linebreak.t()
          | Math.t()
          | Link.t()
          | Raw.t()
          | Quote.t()
          | List.t()
          | ListItem.t()
          | EnumList.t()
          | EnumItem.t()
          | Label.t()
          | Ref.t()
          | Align.t()
          | Block.t()
          | Hide.t()
          | Repeat.t()
          | Place.t()
          | VSpace.t()
          | HSpace.t()
          | Pad.t()
          | Stack.t()
          | Rect.t()
          | Square.t()
          | Circle.t()
          | Ellipse.t()
          | Line.t()
          | Polygon.t()
          | Outline.t()
          | Title.t()
          | TermList.t()
          | TermItem.t()
          | Footnote.t()
          | Divider.t()
          | Grid.t()
          | GridCell.t()
          | LocalSet.t()
          | RawTypst.t()
          | ShowRule.t()
          | Sequence.t()

  @doc "Flatten nested Sequences."
  @spec flatten([t()]) :: [t()]
  def flatten(nodes) do
    Enum.flat_map(nodes, fn
      %Sequence{children: children} -> flatten(children)
      node -> [node]
    end)
  end

  @doc "Convert a value to a content list."
  @spec to_content(t() | String.t() | [t()] | nil) :: [t()]
  def to_content(nil), do: []
  def to_content(%_{} = node), do: [node]
  def to_content(str) when is_binary(str), do: [%Text{text: str}]
  def to_content(list) when is_list(list), do: Enum.flat_map(list, &to_content/1)

  def to_content(other) do
    raise ArgumentError,
          "expected a content struct, string, or list, got: #{inspect(other)}"
  end
end
