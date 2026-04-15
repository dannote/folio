defmodule Folio do
  @moduledoc """
  Print-quality PDF from Markdown + Elixir, powered by Typst.

  ## Usage

      use Folio

      def generate(report) do
        Folio.to_pdf!("# Report\n\nSome content here.")
      end
  """

  alias Folio.{Content, Document, Styles, Value}

  defmacro __using__(_opts \\ []) do
    quote do
      import Folio.DSL
      import Folio.Sigil
      import Folio.Value
    end
  end

  @doc "Compile a document to PDF bytes."
  @spec to_pdf(Document.t() | String.t(), map()) ::
          {:ok, binary()} | {:error, term()}
  def to_pdf(source, assigns \\ %{})

  def to_pdf(%Document{} = doc, _assigns) do
    Folio.Native.compile(doc, :pdf)
  end

  def to_pdf(markdown, assigns) when is_binary(markdown) do
    doc = parse_markdown(markdown, assigns)
    Folio.Native.compile(doc, :pdf)
  end

  @doc "Compile to PDF, raising on error."
  @spec to_pdf!(Document.t() | String.t(), map()) :: binary()
  def to_pdf!(source, assigns \\ %{}) do
    case to_pdf(source, assigns) do
      {:ok, pdf} -> pdf
      {:error, reason} -> raise Folio.CompileError, reason: reason
    end
  end

  @doc "Compile a document to SVG strings (one per page)."
  @spec to_svg(Document.t() | String.t(), map()) ::
          {:ok, [binary()]} | {:error, term()}
  def to_svg(source, assigns \\ %{})

  def to_svg(%Document{} = doc, _assigns) do
    Folio.Native.compile(doc, :svg)
  end

  def to_svg(markdown, assigns) when is_binary(markdown) do
    doc = parse_markdown(markdown, assigns)
    Folio.Native.compile(doc, :svg)
  end

  @doc "Compile a document to PNG images (one per page)."
  @spec to_png(Document.t() | String.t(), map()) ::
          {:ok, [binary()]} | {:error, term()}
  def to_png(source, assigns \\ %{})

  def to_png(%Document{} = doc, _assigns) do
    Folio.Native.compile(doc, :png)
  end

  def to_png(markdown, assigns) when is_binary(markdown) do
    doc = parse_markdown(markdown, assigns)
    Folio.Native.compile(doc, :png)
  end

  @doc "Build a document with styles using a DSL block."
  defmacro doc(opts \\ [], do: body) do
    quote do
      doc = Folio.Document.configure(unquote(opts))
      unquote(body)
      doc
    end
  end

  defp parse_markdown(markdown, _assigns) do
    case Folio.Native.parse_markdown(markdown) do
      {:ok, content} -> %Document{content: content, styles: []}
      {:error, reason} -> raise Folio.ParseError, reason: reason
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
