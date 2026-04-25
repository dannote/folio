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
        |> Folio.Document.attach_file("logo.png", File.read!("logo.png"))
        |> Folio.Document.add_style(Folio.Styles.page_numbering("1"))
        |> Folio.Document.add_content("# Hello\\n\\nWorld")

      {:ok, pdf} = Folio.to_pdf(doc)

  ## File management

  For one-off files, use `register_file/2`. For session-scoped isolation,
  use `Folio.Document.attach_file/3` — files live only within that document.
  """

  @doc "Imports `Folio.DSL` and `Folio.Sigil`."
  defmacro __using__(_opts) do
    quote do
      import Folio.DSL
      import Folio.Styles
      import Folio.Sigil
    end
  end

  @doc """
  Parse markdown into content nodes.

      {:ok, nodes} = Folio.parse_markdown("# Hello\\n\\nWorld")

  Returns `{:error, Folio.ParseError.t()}` on failure.
  """
  @spec parse_markdown(String.t()) :: {:ok, [Folio.Content.t()]} | {:error, Folio.ParseError.t()}
  def parse_markdown(markdown) when is_binary(markdown) do
    {:ok, Folio.Native.parse_markdown(markdown)}
  rescue
    e in ErlangError ->
      {:error, Folio.ParseError.new(Exception.message(e))}
  end

  @doc """
  Parse markdown into content nodes, raising on error.

      nodes = Folio.parse_markdown!("# Hello\\n\\nWorld")

  Raises `Folio.ParseError` on failure.
  """
  @spec parse_markdown!(String.t()) :: [Folio.Content.t()]
  def parse_markdown!(markdown) when is_binary(markdown) do
    case parse_markdown(markdown) do
      {:ok, nodes} -> nodes
      {:error, error} -> raise error
    end
  end

  @type source :: String.t() | [Folio.Content.t()] | Folio.Document.t()
  @type compile_result(result) :: {:ok, result} | {:error, Folio.CompileError.t()}

  @doc """
  Compile to PDF bytes.

  Accepts markdown strings, content node lists, or `Folio.Document` structs.

      {:ok, pdf} = Folio.to_pdf("# Hello")
      {:ok, pdf} = Folio.to_pdf(doc)
  """
  @spec to_pdf(source(), keyword()) :: compile_result(binary())
  def to_pdf(source, opts \\ [])

  def to_pdf(source, opts) do
    with {:ok, {content, styles, files}} <- normalize_source(source, opts) do
      wrap_call(
        fn -> Folio.Native.compile_pdf(content, styles, files) end,
        &Folio.CompileError.new/1
      )
    end
  end

  @doc """
  Compile to SVG strings (one per page).

      {:ok, [page1_svg, page2_svg]} = Folio.to_svg("# Hello")
  """
  @spec to_svg(source(), keyword()) :: compile_result([String.t()])
  def to_svg(source, opts \\ [])

  def to_svg(source, opts) do
    with {:ok, {content, styles, files}} <- normalize_source(source, opts) do
      wrap_call(
        fn -> Folio.Native.compile_svg(content, styles, files) end,
        &Folio.CompileError.new/1
      )
    end
  end

  @doc """
  Compile to PNG images (one per page).

  Each page is rendered and encoded independently so peak memory
  is proportional to the largest page, not the total page count.

      {:ok, [page1_png, page2_png]} = Folio.to_png("# Hello")
      {:ok, pngs} = Folio.to_png("# Hello", dpi: 3.0)

  Options:

    * `:dpi` — render scale factor (default: `2.0`).
      `1.0` = 72 DPI, `2.0` = 144 DPI, `3.0` = 216 DPI.
  """
  @spec to_png(source(), keyword()) :: compile_result([binary()])
  def to_png(source, opts \\ [])

  def to_png(source, opts) do
    dpi = Keyword.get(opts, :dpi, 2.0)

    with {:ok, {content, styles, files}} <- normalize_source(source, opts) do
      wrap_call(
        fn -> Folio.Native.compile_png(content, styles, files, dpi) end,
        &Folio.CompileError.new/1
      )
    end
  end

  @doc """
  Register a file globally for use in documents (images, bibliography, etc).

  Files registered here are shared across all compile calls for the
  lifetime of the BEAM VM. For session-scoped isolation, prefer
  `Folio.Document.attach_file/3` instead.
  """
  @spec register_file(String.t(), binary()) :: :ok
  def register_file(path, data) when is_binary(path) and is_binary(data) do
    Folio.Native.register_file(path, data)
    :ok
  end

  @doc """
  Unregister a previously registered global file, freeing its memory.

      Folio.unregister_file("chart.png")
  """
  @spec unregister_file(String.t()) :: :ok
  def unregister_file(path) when is_binary(path) do
    Folio.Native.unregister_file(path)
    :ok
  end

  @spec normalize_source(source(), keyword()) ::
          {:ok, {[Folio.Content.t()], [Folio.Styles.rule()], %{String.t() => binary()}}}
          | {:error, Folio.ParseError.t()}
  defp normalize_source(
         %Folio.Document{content: content, styles: doc_styles, files: doc_files},
         opts
       ) do
    content = Folio.Show.apply(content)
    opts_styles = Keyword.get(opts, :styles, [])
    {:ok, {content, opts_styles ++ doc_styles, doc_files}}
  end

  defp normalize_source(markdown, opts) when is_binary(markdown) do
    case parse_markdown(markdown) do
      {:ok, nodes} ->
        nodes = Folio.Show.apply(nodes)
        {:ok, {nodes, Keyword.get(opts, :styles, []), %{}}}

      {:error, _} = err ->
        err
    end
  end

  defp normalize_source(content, opts) when is_list(content) do
    content = Folio.Show.apply(content)
    {:ok, {content, Keyword.get(opts, :styles, []), %{}}}
  end

  @spec wrap_call((-> result), (String.t() -> exception)) :: {:ok, result} | {:error, exception}
        when result: var, exception: Exception.t()
  defp wrap_call(fun, error_builder) do
    {:ok, fun.()}
  rescue
    e in ErlangError ->
      reason = format_nif_error(Exception.message(e))
      {:error, error_builder.(reason)}
  end

  defp format_nif_error(msg) do
    case Regex.run(~r/Could not decode field :(\w+) on %Ex(\w+)\{\}/, msg) do
      [_, field, type] ->
        "invalid value for #{type}.#{field} — check that the field type matches the DSL function signature"

      _ ->
        msg
    end
  end
end
