defmodule Folio.Document do
  @moduledoc """
  A complete document with content, styles, and file attachments.
  """

  alias Folio.{Content, Styles}

  defstruct content: [], styles: [], files: %{}

  @type t :: %__MODULE__{
          content: [Content.t()],
          styles: [Styles.rule()],
          files: %{String.t() => binary()}
        }

  @doc "Create an empty document."
  @spec new() :: t()
  def new, do: %__MODULE__{content: [], styles: [], files: %{}}

  @doc "Add content to the document."
  @spec add_content(t(), Content.t() | [Content.t()] | String.t()) :: t()
  def add_content(%__MODULE__{content: content} = doc, nodes) do
    new_content = Content.flatten(content ++ Content.to_content(nodes))
    %{doc | content: new_content}
  end

  @doc "Add one or more style rules to the document."
  @spec add_style(t(), Styles.rule() | [Styles.rule()]) :: t()
  def add_style(%__MODULE__{styles: styles} = doc, rules) when is_list(rules) do
    %{doc | styles: styles ++ rules}
  end

  def add_style(%__MODULE__{styles: styles} = doc, rule) do
    %{doc | styles: styles ++ [rule]}
  end

  @doc """
  Attach a file to the document (images, bibliography, etc).

  Files are scoped to this document only — they don't leak across
  independent compile calls. Prefer this over `Folio.register_file/2`
  for session isolation.

      doc =
        Folio.Document.new()
        |> Folio.Document.attach_file("logo.png", File.read!("logo.png"))
        |> Folio.Document.add_content("![Logo](logo.png)")
  """
  @spec attach_file(t(), String.t(), binary()) :: t()
  def attach_file(%__MODULE__{files: files} = doc, path, data)
      when is_binary(path) and is_binary(data) do
    %{doc | files: Map.put(files, path, data)}
  end
end
