defmodule Folio.Styles do
  @moduledoc """
  Style rules that map to Typst's set/show system.
  """

  defmodule SetRule do
    @moduledoc "Maps to `#set element(fields...)`"
    defstruct [:element, :fields]
    @type t :: %__MODULE__{
      element: atom(),
      fields: keyword() | map()
    }
  end

  defmodule ShowSetRule do
    @moduledoc "Maps to `#show selector: set element(fields...)`"
    defstruct [:selector, :element, :fields]
    @type t :: %__MODULE__{
      selector: atom() | {atom(), keyword()},
      element: atom(),
      fields: keyword() | map()
    }
  end

  defmodule ShowRule do
    @moduledoc "Maps to `#show selector: transform_fn`"
    defstruct [:selector, :transform]
    @type t :: %__MODULE__{
      selector: atom() | {atom(), keyword()} | :all,
      transform: atom() | function()
    }
  end

  @type rule :: SetRule.t() | ShowSetRule.t() | ShowRule.t()

  @doc "Create a set rule."
  @spec set(atom(), keyword()) :: SetRule.t()
  def set(element, fields) when is_atom(element) and is_list(fields) do
    %SetRule{element: element, fields: fields}
  end

  @doc "Create a show-set rule."
  @spec show_set(atom() | {atom(), keyword()}, atom(), keyword()) :: ShowSetRule.t()
  def show_set(selector, element, fields) do
    %ShowSetRule{selector: selector, element: element, fields: fields}
  end

  @doc "Create a show-transform rule."
  @spec show(atom() | {atom(), keyword()}, atom() | function()) :: ShowRule.t()
  def show(selector, transform) do
    %ShowRule{selector: selector, transform: transform}
  end

  @doc "Convenience: page setup from keyword options."
  @spec page_setup(keyword()) :: SetRule.t()
  def page_setup(opts) do
    fields =
      opts
      |> Enum.map(fn
        {:margin, v} -> {:margin, v}
        {:paper, v} -> {:paper, v}
        {:width, v} -> {:width, v}
        {:height, v} -> {:height, v}
        {:numbering, v} -> {:numbering, v}
        {:header, v} -> {:header, v}
        {:footer, v} -> {:footer, v}
        {:columns, v} -> {:columns, v}
        {:orientation, v} -> {:orientation, v}
        other -> other
      end)

    %SetRule{element: :page, fields: fields}
  end

  @doc "Convenience: text setup from keyword options."
  @spec text_setup(keyword()) :: SetRule.t()
  def text_setup(opts) do
    %SetRule{element: :text, fields: opts}
  end
end
