defmodule Folio do
  @moduledoc """
  Print-quality PDF from Markdown + Elixir, powered by Typst.

  ## Usage

      use Folio

      pdf = Folio.to_pdf("# Report\\n\\nSome content here.")

      # With custom styles
      pdf = Folio.to_pdf("# Report", styles: [Folio.Styles.page_size(width: 595, height: 842)])

  ## Image loading

      Folio.register_file("logo.png", File.read!("logo.png"))
      pdf = Folio.to_pdf("![Logo](logo.png)")
  """

  defmacro __using__(_opts \\ []) do
    quote do
      import Folio.DSL
      import Folio.Sigil
      import Folio.Value
    end
  end

  @doc "Parse markdown into content nodes."
  @spec parse_markdown(String.t()) :: [Folio.Content.t()]
  def parse_markdown(markdown) when is_binary(markdown) do
    Folio.Native.parse_markdown(markdown)
  end

  @doc "Compile markdown or content to PDF bytes."
  @spec to_pdf(String.t() | [Folio.Content.t()], keyword()) :: binary()
  def to_pdf(source, opts \\ [])

  def to_pdf(markdown, opts) when is_binary(markdown) do
    markdown |> parse_markdown() |> to_pdf(opts)
  end

  def to_pdf(content, opts) when is_list(content) do
    styles = Keyword.get(opts, :styles, [])
    Folio.Native.compile_pdf(content, styles)
  end

  @doc "Compile markdown or content to SVG strings (one per page)."
  @spec to_svg(String.t() | [Folio.Content.t()], keyword()) :: [String.t()]
  def to_svg(source, opts \\ [])

  def to_svg(markdown, opts) when is_binary(markdown) do
    markdown |> parse_markdown() |> to_svg(opts)
  end

  def to_svg(content, opts) when is_list(content) do
    styles = Keyword.get(opts, :styles, [])
    Folio.Native.compile_svg(content, styles)
  end

  @doc "Compile markdown or content to PNG images (one per page)."
  @spec to_png(String.t() | [Folio.Content.t()], keyword()) :: [binary()]
  def to_png(source, opts \\ [])

  def to_png(markdown, opts) when is_binary(markdown) do
    markdown |> parse_markdown() |> to_png(opts)
  end

  def to_png(content, opts) when is_list(content) do
    styles = Keyword.get(opts, :styles, [])
    Folio.Native.compile_png(content, styles)
  end

  @doc "Register a file for use in documents (images, etc)."
  @spec register_file(String.t(), binary()) :: :ok
  def register_file(path, data) when is_binary(path) and is_binary(data) do
    case Folio.Native.register_file(path, data) do
      :ok -> :ok
      "ok" -> :ok
    end
  end
end

defmodule Folio.CompileError do
  defexception [:reason]
  @impl true
  def message(%{reason: reason}), do: "Folio compile error: #{inspect(reason)}"
end

defmodule Folio.ParseError do
  defexception [:reason]
  @impl true
  def message(%{reason: reason}), do: "Folio parse error: #{inspect(reason)}"
end
