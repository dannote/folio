defmodule Folio do
  @moduledoc """
  Print-quality PDF from Markdown + Elixir, powered by Typst.

      use Folio

      content = ~MD""
      # Report

      Some **bold** content with $x^2$ math.
      ""

      {:ok, pdf} = Folio.to_pdf(content)

  ## Styles

      {:ok, pdf} = Folio.to_pdf("Hello", styles: [
        Folio.Styles.page_size(width: 595, height: 842),
        Folio.Styles.font_family(["Helvetica"]),
      ])

  ## Document pipeline

      doc =
        Folio.Document.new()
        |> Folio.Document.add_style(Folio.Styles.page_numbering("1"))
        |> Folio.Document.add_content("# Hello\\n\\nWorld")

      {:ok, pdf} = Folio.to_pdf(doc)

  ## Images

      Folio.register_file("logo.png", File.read!("logo.png"))
      {:ok, pdf} = Folio.to_pdf("![Logo](logo.png)")
  """

  defmacro __using__(_opts) do
    quote do
      import Folio.DSL
      import Folio.Sigil
    end
  end

  @doc """
  Parse markdown into content nodes.

      nodes = Folio.parse_markdown("# Hello\\n\\nWorld")
      [%Folio.Content.Heading{level: 1, ...}, %Folio.Content.Paragraph{...}] = nodes

  Raises `Folio.ParseError` on invalid input.
  """
  @spec parse_markdown(String.t()) :: [Folio.Content.t()]
  def parse_markdown(markdown) when is_binary(markdown) do
    Folio.Native.parse_markdown(markdown)
  rescue
    e in ErlangError ->
      raise Folio.ParseError, Exception.message(e)
  end

  @doc """
  Compile to PDF bytes.

  Accepts markdown strings, content node lists, or `Folio.Document` structs.

      {:ok, pdf} = Folio.to_pdf("# Hello")
      {:ok, pdf} = Folio.to_pdf([heading(1, "Hello")], styles: [...])
      {:ok, pdf} = Folio.to_pdf(doc)
  """
  @spec to_pdf(String.t() | [Folio.Content.t()] | Folio.Document.t(), keyword()) ::
          {:ok, binary()} | {:error, Folio.CompileError.t()}
  def to_pdf(source, opts \\ [])

  def to_pdf(%Folio.Document{content: content, styles: doc_styles}, opts) do
    merged = if Keyword.has_key?(opts, :styles), do: opts, else: Keyword.put(opts, :styles, doc_styles)
    to_pdf(content, merged)
  end

  def to_pdf(markdown, opts) when is_binary(markdown) do
    to_pdf(parse_markdown(markdown), opts)
  end

  def to_pdf(content, opts) when is_list(content) do
    styles = Keyword.get(opts, :styles, [])
    wrap_call(fn -> Folio.Native.compile_pdf(content, styles) end, Folio.CompileError)
  end

  @doc """
  Compile to SVG strings (one per page).

      {:ok, [page1_svg, page2_svg]} = Folio.to_svg("# Hello")
  """
  @spec to_svg(String.t() | [Folio.Content.t()] | Folio.Document.t(), keyword()) ::
          {:ok, [String.t()]} | {:error, Folio.CompileError.t()}
  def to_svg(source, opts \\ [])

  def to_svg(%Folio.Document{content: content, styles: doc_styles}, opts) do
    merged = if Keyword.has_key?(opts, :styles), do: opts, else: Keyword.put(opts, :styles, doc_styles)
    to_svg(content, merged)
  end

  def to_svg(markdown, opts) when is_binary(markdown) do
    to_svg(parse_markdown(markdown), opts)
  end

  def to_svg(content, opts) when is_list(content) do
    styles = Keyword.get(opts, :styles, [])
    wrap_call(fn -> Folio.Native.compile_svg(content, styles) end, Folio.CompileError)
  end

  @doc """
  Compile to PNG images (one per page).

      {:ok, [page1_png, page2_png]} = Folio.to_png("# Hello")
  """
  @spec to_png(String.t() | [Folio.Content.t()] | Folio.Document.t(), keyword()) ::
          {:ok, [binary()]} | {:error, Folio.CompileError.t()}
  def to_png(source, opts \\ [])

  def to_png(%Folio.Document{content: content, styles: doc_styles}, opts) do
    merged = if Keyword.has_key?(opts, :styles), do: opts, else: Keyword.put(opts, :styles, doc_styles)
    to_png(content, merged)
  end

  def to_png(markdown, opts) when is_binary(markdown) do
    to_png(parse_markdown(markdown), opts)
  end

  def to_png(content, opts) when is_list(content) do
    styles = Keyword.get(opts, :styles, [])
    wrap_call(fn -> Folio.Native.compile_png(content, styles) end, Folio.CompileError)
  end

  @doc """
  Register a file for use in documents (images, etc).

      Folio.register_file("chart.png", File.read!("chart.png"))
      {:ok, pdf} = Folio.to_pdf("![Chart](chart.png)")
  """
  @spec register_file(String.t(), binary()) :: :ok
  def register_file(path, data) when is_binary(path) and is_binary(data) do
    Folio.Native.register_file(path, data)
    :ok
  end

  @spec wrap_call((() -> result), module()) :: {:ok, result} | {:error, struct()}
        when result: var
  defp wrap_call(fun, error_mod) do
    {:ok, fun.()}
  rescue
    e in ErlangError ->
      {:error, error_mod.new(Exception.message(e))}
  end
end
