defmodule Folio.Content do
  @moduledoc """
  Typed content nodes that map 1:1 to Typst elements.

  Every struct has matching fields in `native/folio_nif/src/types.rs`.
  The Rust NifStruct `#[module = "Folio.Content.*"]` must match exactly.
  """

  defmodule Text do
    @moduledoc "Plain text."
    defstruct [:text]
    @type t :: %__MODULE__{text: String.t()}
  end

  defmodule Space do
    @moduledoc "Whitespace."
    defstruct []
    @type t :: %__MODULE__{}
  end

  defmodule Heading do
    @moduledoc "Section heading (h1-h6)."
    defstruct [:body, :level]
    @type t :: %__MODULE__{body: [Folio.Content.t()], level: 1..6}
  end

  defmodule Paragraph do
    @moduledoc "Paragraph."
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

  defmodule Image do
    @moduledoc "Image."
    defstruct [:src, :width, :height, :fit]
    @type t :: %__MODULE__{
      src: String.t(),
      width: String.t() | nil,
      height: String.t() | nil,
      fit: String.t() | nil
    }
  end

  defmodule Figure do
    @moduledoc "Figure with optional caption."
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
    @moduledoc "Table."
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
    defstruct [:body, :colspan, :rowspan, :align]
    @type t :: %__MODULE__{
      body: [Folio.Content.t()],
      colspan: pos_integer() | nil,
      rowspan: pos_integer() | nil,
      align: String.t() | nil
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
    @moduledoc "Math expression (Typst math syntax)."
    defstruct [:content, :block]
    @type t :: %__MODULE__{content: String.t(), block: boolean()}
  end

  defmodule Link do
    @moduledoc "Hyperlink."
    defstruct [:url, :body]
    @type t :: %__MODULE__{url: String.t(), body: [Folio.Content.t()]}
  end

  defmodule Raw do
    @moduledoc "Raw / code block."
    defstruct [:text, :lang, :block]
    @type t :: %__MODULE__{text: String.t(), lang: String.t() | nil, block: boolean()}
  end

  defmodule Quote do
    @moduledoc "Block or inline quote."
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

  defmodule Enum do
    @moduledoc "Numbered list."
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
    @moduledoc "Label for cross-references."
    defstruct [:name]
    @type t :: %__MODULE__{name: String.t()}
  end

  defmodule Ref do
    @moduledoc "Cross-reference to a label."
    defstruct [:target, :supplement]
    @type t :: %__MODULE__{target: String.t(), supplement: [Folio.Content.t()] | nil}
  end

  defmodule Align do
    @moduledoc "Alignment wrapper."
    defstruct [:alignment, :body]
    @type t :: %__MODULE__{alignment: String.t(), body: [Folio.Content.t()]}
  end

  defmodule Block do
    @moduledoc "Block container."
    defstruct [:body, :width, :height, :above, :below]
    @type t :: %__MODULE__{
      body: [Folio.Content.t()],
      width: String.t() | nil,
      height: String.t() | nil,
      above: String.t() | nil,
      below: String.t() | nil
    }
  end

  defmodule Sequence do
    @moduledoc "Sequence of content nodes (internal)."
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
