defmodule Folio.Content do
  @moduledoc """
  Typed content nodes that map 1:1 to Typst elements.

  Every struct here has a corresponding Rust type in the NIF
  that constructs the native `typst::Content` tree.
  """

  defmodule Text do
    @moduledoc "Plain text. Maps to `TextElem`."
    defstruct [:text]
    @type t :: %__MODULE__{text: String.t()}
  end

  defmodule Space do
    @moduledoc "Whitespace."
    defstruct []
    @type t :: %__MODULE__{}
  end

  defmodule Heading do
    @moduledoc "Section heading. Maps to `HeadingElem`."
    defstruct [:body, :level]
    @type t :: %__MODULE__{body: [t()], level: pos_integer()}
  end

  defmodule Paragraph do
    @moduledoc "Paragraph. Maps to implicit paragraph grouping."
    defstruct [:body]
    @type t :: %__MODULE__{body: [t()]}
  end

  defmodule Strong do
    @moduledoc "Bold text. Maps to `StrongElem`."
    defstruct [:body]
    @type t :: %__MODULE__{body: [t()]}
  end

  defmodule Emph do
    @moduledoc "Italic text. Maps to `EmphElem`."
    defstruct [:body]
    @type t :: %__MODULE__{body: [t()]}
  end

  defmodule Image do
    @moduledoc "Image. Maps to `ImageElem`."
    defstruct [:src, :width, :height, :fit]
    @type t :: %__MODULE__{
      src: String.t(),
      width: Folio.Value.t() | nil,
      height: Folio.Value.t() | nil,
      fit: :cover | :contain | :stretch | nil
    }
  end

  defmodule Figure do
    @moduledoc "Figure with optional caption. Maps to `FigureElem`."
    defstruct [:body, :caption, :placement, :scope, :numbering, :separator]
    @type t :: %__MODULE__{
      body: [Folio.Content.t()],
      caption: [Folio.Content.t()] | nil,
      placement: :top | :bottom | :auto | nil,
      scope: :parent | :children | nil,
      numbering: String.t() | :none | nil,
      separator: String.t() | nil
    }
  end

  defmodule Table do
    @moduledoc "Table. Maps to `TableElem`."
    defstruct [:columns, :rows, :children, :stroke, :gutter, :align]
    @type t :: %__MODULE__{
      columns: [Folio.Value.t()],
      rows: [Folio.Value.t()],
      children: [Folio.Content.t()],
      stroke: Folio.Value.t() | nil,
      gutter: Folio.Value.t() | nil,
      align: :left | :center | :right | nil
    }
  end

  defmodule TableHeader do
    @moduledoc "Table header row. Maps to `TableHeader`."
    defstruct [:children]
    @type t :: %__MODULE__{children: [Folio.Content.t()]}
  end

  defmodule TableRow do
    @moduledoc "Table row (implicit in Typst)."
    defstruct [:children]
    @type t :: %__MODULE__{children: [Folio.Content.t()]}
  end

  defmodule TableCell do
    @moduledoc "Table cell. Maps to `TableCell`."
    defstruct [:body, :colspan, :rowspan, :align]
    @type t :: %__MODULE__{
      body: [Folio.Content.t()],
      colspan: pos_integer() | nil,
      rowspan: pos_integer() | nil,
      align: :left | :center | :right | nil
    }
  end

  defmodule Columns do
    @moduledoc "Multi-column layout. Maps to `ColumnsElem`."
    defstruct [:count, :body, :gutter]
    @type t :: %__MODULE__{
      count: pos_integer(),
      body: [Folio.Content.t()],
      gutter: Folio.Value.t() | nil
    }
  end

  defmodule Pagebreak do
    @moduledoc "Page break. Maps to `PagebreakElem`."
    defstruct [:weak]
    @type t :: %__MODULE__{weak: boolean()}
  end

  defmodule Parbreak do
    @moduledoc "Paragraph break."
    defstruct []
    @type t :: %__MODULE__{}
  end

  defmodule Linebreak do
    @moduledoc "Line break. Maps to `LinebreakElem`."
    defstruct []
    @type t :: %__MODULE__{}
  end

  defmodule Math do
    @moduledoc "Math expression. Parsed by Typst's math parser in Rust."
    defstruct [:content, :block]
    @type t :: %__MODULE__{content: String.t(), block: boolean()}
  end

  defmodule Bibliography do
    @moduledoc "Bibliography. Maps to `Bibliography`."
    defstruct [:source, :style, :full]
    @type t :: %__MODULE__{
      source: String.t(),
      style: String.t() | nil,
      full: boolean() | nil
    }
  end

  defmodule Link do
    @moduledoc "Hyperlink. Maps to `LinkElem`."
    defstruct [:url, :body]
    @type t :: %__MODULE__{url: String.t(), body: [Folio.Content.t()] | []}
  end

  defmodule Raw do
    @moduledoc "Raw/code text. Maps to `RawElem`."
    defstruct [:text, :lang, :block]
    @type t :: %__MODULE__{text: String.t(), lang: String.t() | nil, block: boolean()}
  end

  defmodule Quote do
    @moduledoc "Block quote. Maps to `QuoteElem`."
    defstruct [:body, :block, :attribution]
    @type t :: %__MODULE__{
      body: [Folio.Content.t()],
      block: boolean(),
      attribution: [Folio.Content.t()] | nil
    }
  end

  defmodule List do
    @moduledoc "Bullet list. Maps to `ListItem` sequence."
    defstruct [:children, :tight, :marker]
    @type t :: %__MODULE__{
      children: [Folio.Content.t()],
      tight: boolean(),
      marker: String.t() | nil
    }
  end

  defmodule ListItem do
    @moduledoc "Bullet list item. Maps to `ListItem`."
    defstruct [:body]
    @type t :: %__MODULE__{body: [Folio.Content.t()]}
  end

  defmodule Enum do
    @moduledoc "Numbered list. Maps to `EnumItem` sequence."
    defstruct [:children, :tight, :start]
    @type t :: %__MODULE__{
      children: [Folio.Content.t()],
      tight: boolean(),
      start: pos_integer() | nil
    }
  end

  defmodule EnumItem do
    @moduledoc "Numbered list item. Maps to `EnumItem`."
    defstruct [:body, :number]
    @type t :: %__MODULE__{body: [Folio.Content.t()], number: pos_integer() | nil}
  end

  defmodule Label do
    @moduledoc "Label for references. Maps to `<name>`."
    defstruct [:name]
    @type t :: %__MODULE__{name: String.t()}
  end

  defmodule Ref do
    @moduledoc "Reference. Maps to `@target`."
    defstruct [:target, :supplement]
    @type t :: %__MODULE__{target: String.t(), supplement: [Folio.Content.t()] | nil}
  end

  defmodule Align do
    @moduledoc "Alignment wrapper. Maps to `align()`."
    defstruct [:alignment, :body]
    @type t :: %__MODULE__{
      alignment: :left | :center | :right,
      body: [Folio.Content.t()]
    }
  end

  defmodule Block do
    @moduledoc "Block-level container. Maps to `block()`."
    defstruct [:body, :width, :height, :above, :below]
    @type t :: %__MODULE__{
      body: [Folio.Content.t()],
      width: Folio.Value.t() | nil,
      height: Folio.Value.t() | nil,
      above: Folio.Value.t() | nil,
      below: Folio.Value.t() | nil
    }
  end

  defmodule Pad do
    @moduledoc "Padding. Maps to `pad()`."
    defstruct [:body, :left, :right, :top, :bottom, :x, :y, :rest]
    @type t :: %__MODULE__{
      body: [Folio.Content.t()],
      left: Folio.Value.t() | nil,
      right: Folio.Value.t() | nil,
      top: Folio.Value.t() | nil,
      bottom: Folio.Value.t() | nil,
      x: Folio.Value.t() | nil,
      y: Folio.Value.t() | nil,
      rest: Folio.Value.t() | nil
    }
  end

  defmodule Grid do
    @moduledoc "Grid layout. Maps to `GridElem`."
    defstruct [:columns, :rows, :children, :gutter, :stroke, :align]
    @type t :: %__MODULE__{
      columns: [Folio.Value.t()],
      rows: [Folio.Value.t()],
      children: [Folio.Content.t()],
      gutter: Folio.Value.t() | nil,
      stroke: Folio.Value.t() | nil,
      align: :left | :center | :right | nil
    }
  end

  defmodule Stack do
    @moduledoc "Stack layout. Maps to `StackElem`."
    defstruct [:dir, :children, :gutter, :spacing]
    @type t :: %__MODULE__{
      dir: :ltr | :rtl | :ttb | :btt,
      children: [Folio.Content.t()],
      gutter: Folio.Value.t() | nil,
      spacing: Folio.Value.t() | nil
    }
  end

  defmodule Sequence do
    @moduledoc "Sequence of content nodes."
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
          | Image.t()
          | Figure.t()
          | Table.t()
          | TableHeader.t()
          | TableRow.t()
          | TableCell.t()
          | Columns.t()
          | Pagebreak.t()
          | Parbreak.t()
          | Linebreak.t()
          | Math.t()
          | Bibliography.t()
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
          | Pad.t()
          | Grid.t()
          | Stack.t()
          | Sequence.t()

  @doc "Wrap a string as Text content."
  @spec text(String.t()) :: Text.t()
  def text(str), do: %Text{text: str}

  @doc "Wrap a list of content nodes."
  @spec sequence([t()]) :: Sequence.t()
  def sequence(children), do: %Sequence{children: children}

  @doc "Flatten nested sequences."
  @spec flatten([t()]) :: [t()]
  def flatten(nodes) do
    Elixir.Enum.flat_map(nodes, fn
      %Sequence{children: children} -> flatten(children)
      node -> [node]
    end)
  end

  @doc "Convert a string or content to content list."
  @spec to_content(t() | String.t() | [t()]) :: [t()]
  def to_content(%_mod{} = node), do: [node]
  def to_content(str) when is_binary(str), do: [%Text{text: str}]
  def to_content(list) when is_list(list), do: Elixir.Enum.flat_map(list, &to_content/1)
end
