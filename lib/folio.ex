defmodule Folio do
  @moduledoc """
  Print-quality PDF from Markdown + Elixir, powered by Typst.

  ## Usage

      use Folio

      def generate(report) do
        Folio.to_pdf!("# Report\\n\\nSome content here.")
      end
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
  @spec to_pdf(String.t() | [Folio.Content.t()]) :: binary()
  def to_pdf(markdown) when is_binary(markdown) do
    markdown |> parse_markdown() |> to_pdf()
  end

  def to_pdf(content) when is_list(content) do
    Folio.Native.compile_pdf(content)
  end

  @doc "Compile markdown or content to SVG strings (one per page)."
  @spec to_svg(String.t() | [Folio.Content.t()]) :: [String.t()]
  def to_svg(markdown) when is_binary(markdown) do
    markdown |> parse_markdown() |> to_svg()
  end

  def to_svg(content) when is_list(content) do
    Folio.Native.compile_svg(content)
  end

  @doc "Compile markdown or content to PNG images (one per page)."
  @spec to_png(String.t() | [Folio.Content.t()]) :: [binary()]
  def to_png(markdown) when is_binary(markdown) do
    markdown |> parse_markdown() |> to_png()
  end

  def to_png(content) when is_list(content) do
    Folio.Native.compile_png(content)
  end

  @doc "Compile to PDF, writing to file."
  @spec to_pdf_file(String.t() | [Folio.Content.t()], String.t()) :: :ok | {:error, term()}
  def to_pdf_file(source, path) do
    File.write(path, to_pdf(source))
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
