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
      reraise Folio.ParseError.new(Exception.message(e)), __STACKTRACE__
  end

  @type source :: String.t() | [Folio.Content.t()] | Folio.Document.t()
  @type compile_result(result) :: {:ok, result} | {:error, Folio.CompileError.t()}

  @doc """
  Compile to PDF bytes.

  Accepts markdown strings, content node lists, or `Folio.Document` structs.

      {:ok, pdf} = Folio.to_pdf("# Hello")
      {:ok, pdf} = Folio.to_pdf([heading(1, "Hello")], styles: [...])
      {:ok, pdf} = Folio.to_pdf(doc)
  """
  @spec to_pdf(source(), keyword()) :: compile_result(binary())
  def to_pdf(source, opts \\ [])

  def to_pdf(source, opts) do
    {content, styles} = normalize_source(source, opts)
    wrap_call(fn -> Folio.Native.compile_pdf(content, styles) end, &Folio.CompileError.new/1)
  end

  @doc """
  Compile to SVG strings (one per page).

      {:ok, [page1_svg, page2_svg]} = Folio.to_svg("# Hello")
  """
  @spec to_svg(source(), keyword()) :: compile_result([String.t()])
  def to_svg(source, opts \\ [])

  def to_svg(source, opts) do
    {content, styles} = normalize_source(source, opts)
    wrap_call(fn -> Folio.Native.compile_svg(content, styles) end, &Folio.CompileError.new/1)
  end

  @doc """
  Compile to PNG images (one per page).

      {:ok, [page1_png, page2_png]} = Folio.to_png("# Hello")
  """
  @spec to_png(source(), keyword()) :: compile_result([binary()])
  def to_png(source, opts \\ [])

  def to_png(source, opts) do
    {content, styles} = normalize_source(source, opts)
    wrap_call(fn -> Folio.Native.compile_png(content, styles) end, &Folio.CompileError.new/1)
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

  @spec normalize_source(source(), keyword()) :: {[Folio.Content.t()], [Folio.Styles.rule()]}
  defp normalize_source(%Folio.Document{content: content, styles: doc_styles}, opts) do
    opts_styles = Keyword.get(opts, :styles, [])
    {content, opts_styles ++ doc_styles}
  end

  defp normalize_source(markdown, opts) when is_binary(markdown) do
    {parse_markdown(markdown), Keyword.get(opts, :styles, [])}
  end

  defp normalize_source(content, opts) when is_list(content) do
    {content, Keyword.get(opts, :styles, [])}
  end

  @spec wrap_call((-> result), (String.t() -> exception)) :: {:ok, result} | {:error, exception}
        when result: var, exception: Exception.t()
  defp wrap_call(fun, error_builder) do
    {:ok, fun.()}
  rescue
    e in ErlangError ->
      {:error, error_builder.(Exception.message(e))}
  end
end
