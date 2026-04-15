defmodule Folio.Document do
  @moduledoc """
  A complete document with content and styles.
  """

  alias Folio.{Content, Styles}

  defstruct [:content, :styles]

  @type t :: %__MODULE__{
    content: [Content.t()],
    styles: [Styles.rule()]
  }

  @doc "Create an empty document."
  @spec new() :: t()
  def new, do: %__MODULE__{content: [], styles: []}

  @doc "Add content to the document."
  @spec add_content(t(), Content.t() | [Content.t()] | String.t()) :: t()
  def add_content(%__MODULE__{content: content} = doc, nodes) do
    new_content = Content.flatten(content ++ Content.to_content(nodes))
    %{doc | content: new_content}
  end

  @doc "Add a style rule to the document."
  @spec add_style(t(), Styles.rule()) :: t()
  def add_style(%__MODULE__{styles: styles} = doc, rule) do
    %{doc | styles: styles ++ [rule]}
  end

  @doc "Create a document with page and text setup."
  @spec configure(keyword()) :: t()
  def configure(opts) do
    styles =
      []
      |> maybe_add_style(opts, :page, &Styles.page_size/1)
      |> maybe_add_style(opts, :font_size, &Styles.font_size/1)

    %__MODULE__{content: [], styles: styles}
  end

  defp maybe_add_style(styles, opts, key, builder) do
    case Keyword.get(opts, key) do
      nil -> styles
      val -> styles ++ [builder.(val)]
    end
  end
end
