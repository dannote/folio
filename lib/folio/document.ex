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
    styles = []

    styles =
      case Keyword.get(opts, :page) do
        nil -> styles
        page_opts when is_list(page_opts) -> styles ++ [Styles.page_size(page_opts)]
        paper when is_atom(paper) -> styles ++ [Styles.page_paper(to_string(paper))]
      end

    styles =
      case Keyword.get(opts, :font_size) do
        nil -> styles
        size -> styles ++ [Styles.font_size(size)]
      end

    %__MODULE__{content: [], styles: styles}
  end
end
