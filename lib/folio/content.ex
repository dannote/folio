defmodule Folio.Content do
  @moduledoc """
  Typed content nodes that map 1:1 to Typst elements.

  Every struct has matching fields in `native/folio_nif/src/types.rs`.
  The Rust NifStruct `#[module = "Folio.Content.*"]` must match exactly.
  """

  defmodule Text do
    @moduledoc false
    defstruct [:text]
    @type t :: %__MODULE__{text: String.t()}
  end

  defmodule Space do
    @moduledoc false
    defstruct []
    @type t :: %__MODULE__{}
  end

  defmodule Heading do
    @moduledoc false
    defstruct [:body, :level]
    @type t :: %__MODULE__{body: [Folio.Content.t()], level: 1..6}
  end

  defmodule Paragraph do
    @moduledoc false
    defstruct [:body]
    @type t :: %__MODULE__{body: [Folio.Content.t()]}
  end

  defmodule Strong do
    @moduledoc false
    defstruct [:body]
    @type t :: %__MODULE__{body: [Folio.Content.t()]}
  end

  defmodule Emph do
    @moduledoc false
    defstruct [:body]
    @type t :: %__MODULE__{body: [Folio.Content.t()]}
  end

  defmodule Strike do
    @moduledoc false
    defstruct [:body]
    @type t :: %__MODULE__{body: [Folio.Content.t()]}
  end

  defmodule Underline do
    @moduledoc false
    defstruct [:body]
    @type t :: %__MODULE__{body: [Folio.Content.t()]}
  end

  defmodule Highlight do
    @moduledoc false
    defstruct [:body, :fill]
    @type t :: %__MODULE__{body: [Folio.Content.t()], fill: String.t() | nil}
  end

  defmodule Super do
    @moduledoc false
    defstruct [:body]
    @type t :: %__MODULE__{body: [Folio.Content.t()]}
  end

  defmodule Sub do
    @moduledoc false
    defstruct [:body]
    @type t :: %__MODULE__{body: [Folio.Content.t()]}
  end

  defmodule Smallcaps do
    @moduledoc false
    defstruct [:body]
    @type t :: %__MODULE__{body: [Folio.Content.t()]}
  end

  defmodule Image do
    @moduledoc false
    defstruct [:src, :width, :height, :fit]

    @type t :: %__MODULE__{
            src: String.t(),
            width: String.t() | nil,
            height: String.t() | nil,
            fit: String.t() | nil
          }
  end

  defmodule Figure do
    @moduledoc false
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
    @moduledoc false
    defstruct [:columns, :rows, :children, :stroke, :gutter, :align]

    @type t :: %__MODULE__{
            columns: String.t() | nil,
            rows: String.t() | nil,
            children: [Folio.Content.t()],
            stroke: String.t() | nil,
            gutter: String.t() | nil,
            align: String.t() | nil
          }
  end

  defmodule TableHeader do
    @moduledoc false
    defstruct [:children]
    @type t :: %__MODULE__{children: [Folio.Content.t()]}
  end

  defmodule TableRow do
    @moduledoc false
    defstruct [:children]
    @type t :: %__MODULE__{children: [Folio.Content.t()]}
  end

  defmodule TableCell do
    @moduledoc false
    defstruct [:body, :colspan, :rowspan, :align]

    @type t :: %__MODULE__{
            body: [Folio.Content.t()],
            colspan: pos_integer() | nil,
            rowspan: pos_integer() | nil,
            align: String.t() | nil
          }
  end

  defmodule Columns do
    @moduledoc false
    defstruct [:count, :body, :gutter]

    @type t :: %__MODULE__{
            count: pos_integer(),
            body: [Folio.Content.t()],
            gutter: String.t() | nil
          }
  end

  defmodule Colbreak do
    @moduledoc false
    defstruct [:weak]
    @type t :: %__MODULE__{weak: boolean()}
  end

  defmodule Pagebreak do
    @moduledoc false
    defstruct [:weak]
    @type t :: %__MODULE__{weak: boolean()}
  end

  defmodule Parbreak do
    @moduledoc false
    defstruct []
    @type t :: %__MODULE__{}
  end

  defmodule Linebreak do
    @moduledoc false
    defstruct []
    @type t :: %__MODULE__{}
  end

  defmodule Math do
    @moduledoc false
    defstruct [:content, :block]
    @type t :: %__MODULE__{content: String.t(), block: boolean()}
  end

  defmodule Link do
    @moduledoc false
    defstruct [:url, :body]
    @type t :: %__MODULE__{url: String.t(), body: [Folio.Content.t()]}
  end

  defmodule Raw do
    @moduledoc false
    defstruct [:text, :lang, :block]
    @type t :: %__MODULE__{text: String.t(), lang: String.t() | nil, block: boolean()}
  end

  defmodule Quote do
    @moduledoc false
    defstruct [:body, :block, :attribution]

    @type t :: %__MODULE__{
            body: [Folio.Content.t()],
            block: boolean(),
            attribution: [Folio.Content.t()] | nil
          }
  end

  defmodule List do
    @moduledoc false
    defstruct [:children, :tight, :marker]

    @type t :: %__MODULE__{
            children: [Folio.Content.t()],
            tight: boolean(),
            marker: String.t() | nil
          }
  end

  defmodule ListItem do
    @moduledoc false
    defstruct [:body]
    @type t :: %__MODULE__{body: [Folio.Content.t()]}
  end

  defmodule Enum do
    @moduledoc false
    defstruct [:children, :tight, :start]

    @type t :: %__MODULE__{
            children: [Folio.Content.t()],
            tight: boolean(),
            start: pos_integer() | nil
          }
  end

  defmodule EnumItem do
    @moduledoc false
    defstruct [:body, :number]
    @type t :: %__MODULE__{body: [Folio.Content.t()], number: pos_integer() | nil}
  end

  defmodule Label do
    @moduledoc false
    defstruct [:name]
    @type t :: %__MODULE__{name: String.t()}
  end

  defmodule Ref do
    @moduledoc false
    defstruct [:target, :supplement]
    @type t :: %__MODULE__{target: String.t(), supplement: [Folio.Content.t()] | nil}
  end

  defmodule Align do
    @moduledoc false
    defstruct [:alignment, :body]
    @type t :: %__MODULE__{alignment: String.t(), body: [Folio.Content.t()]}
  end

  defmodule Block do
    @moduledoc false
    defstruct [:body, :width, :height, :above, :below]

    @type t :: %__MODULE__{
            body: [Folio.Content.t()],
            width: String.t() | nil,
            height: String.t() | nil,
            above: String.t() | nil,
            below: String.t() | nil
          }
  end

  defmodule Hide do
    @moduledoc false
    defstruct [:body]
    @type t :: %__MODULE__{body: [Folio.Content.t()]}
  end

  defmodule Repeat do
    @moduledoc false
    defstruct [:body]
    @type t :: %__MODULE__{body: [Folio.Content.t()]}
  end

  defmodule Place do
    @moduledoc false
    defstruct [:alignment, :body, :float]

    @type t :: %__MODULE__{
            alignment: String.t() | nil,
            body: [Folio.Content.t()],
            float: boolean() | nil
          }
  end

  defmodule VSpace do
    @moduledoc false
    defstruct [:amount, :weak]
    @type t :: %__MODULE__{amount: String.t(), weak: boolean()}
  end

  defmodule HSpace do
    @moduledoc false
    defstruct [:amount, :weak]
    @type t :: %__MODULE__{amount: String.t(), weak: boolean()}
  end

  defmodule Pad do
    @moduledoc false
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
    @moduledoc false
    defstruct [:dir, :children, :spacing]

    @type t :: %__MODULE__{
            dir: String.t(),
            children: [Folio.Content.t()],
            spacing: String.t() | nil
          }
  end

  defmodule Rect do
    @moduledoc false
    defstruct [:body, :width, :height, :fill, :stroke, :inset, :outset]

    @type t :: %__MODULE__{
            body: [Folio.Content.t()],
            width: String.t() | nil,
            height: String.t() | nil,
            fill: String.t() | nil,
            stroke: String.t() | nil,
            inset: String.t() | nil,
            outset: String.t() | nil
          }
  end

  defmodule Square do
    @moduledoc false
    defstruct [:body, :size, :fill, :stroke, :inset, :outset]

    @type t :: %__MODULE__{
            body: [Folio.Content.t()],
            size: String.t() | nil,
            fill: String.t() | nil,
            stroke: String.t() | nil,
            inset: String.t() | nil,
            outset: String.t() | nil
          }
  end

  defmodule Circle do
    @moduledoc false
    defstruct [:body, :radius, :fill, :stroke, :inset, :outset]

    @type t :: %__MODULE__{
            body: [Folio.Content.t()],
            radius: String.t() | nil,
            fill: String.t() | nil,
            stroke: String.t() | nil,
            inset: String.t() | nil,
            outset: String.t() | nil
          }
  end

  defmodule Ellipse do
    @moduledoc false
    defstruct [:body, :width, :height, :fill, :stroke, :inset, :outset]

    @type t :: %__MODULE__{
            body: [Folio.Content.t()],
            width: String.t() | nil,
            height: String.t() | nil,
            fill: String.t() | nil,
            stroke: String.t() | nil,
            inset: String.t() | nil,
            outset: String.t() | nil
          }
  end

  defmodule Line do
    @moduledoc false
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
    @moduledoc false
    defstruct [:vertices, :fill, :stroke]

    @type t :: %__MODULE__{
            vertices: [String.t()],
            fill: String.t() | nil,
            stroke: String.t() | nil
          }
  end

  defmodule Outline do
    @moduledoc false
    defstruct [:title, :indent, :depth]

    @type t :: %__MODULE__{
            title: String.t() | nil,
            indent: String.t() | nil,
            depth: pos_integer() | nil
          }
  end

  defmodule Title do
    @moduledoc false
    defstruct [:body]
    @type t :: %__MODULE__{body: [Folio.Content.t()]}
  end

  defmodule TermList do
    @moduledoc false
    defstruct [:children, :tight]
    @type t :: %__MODULE__{children: [Folio.Content.t()], tight: boolean()}
  end

  defmodule TermItem do
    @moduledoc false
    defstruct [:term, :description]
    @type t :: %__MODULE__{term: [Folio.Content.t()], description: [Folio.Content.t()]}
  end

  defmodule Footnote do
    @moduledoc false
    defstruct [:body]
    @type t :: %__MODULE__{body: [Folio.Content.t()]}
  end

  defmodule Divider do
    @moduledoc false
    defstruct []
    @type t :: %__MODULE__{}
  end

  defmodule Sequence do
    @moduledoc false
    defstruct [:children]
    @type t :: %__MODULE__{children: [Folio.Content.t()]}
  end

  @type t ::
          Text.t()
          | Space.t()
          | Heading.t()
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
          | Enum.t()
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
          | Sequence.t()

  @doc "Wrap a string as Text."
  @spec text(String.t()) :: Text.t()
  def text(str), do: %Text{text: str}

  @doc "Flatten nested Sequences."
  @spec flatten([t()]) :: [t()]
  def flatten(nodes) do
    Elixir.Enum.flat_map(nodes, fn
      %Sequence{children: children} -> flatten(children)
      node -> [node]
    end)
  end

  @doc "Convert a value to a content list."
  @spec to_content(t() | String.t() | [t()] | nil) :: [t()]
  def to_content(nil), do: []
  def to_content(%_{} = node), do: [node]
  def to_content(str) when is_binary(str), do: [%Text{text: str}]
  def to_content(list) when is_list(list), do: Elixir.Enum.flat_map(list, &to_content/1)
end
