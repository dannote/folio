defmodule Folio do
  @moduledoc """
  Print-quality PDF from Markdown + Elixir, powered by Typst.

      use Folio

      {:ok, pdf} = Folio.to_pdf("# Report\\n\\nSome content here.")

      # With custom styles
      {:ok, pdf} = Folio.to_pdf("# Report", styles: [
        Folio.Styles.page_size(width: 595, height: 842)
      ])

  ## Image loading

      Folio.register_file("logo.png", File.read!("logo.png"))
      {:ok, pdf} = Folio.to_pdf("![Logo](logo.png)")
  """

  defmacro __using__(_opts) do
    quote do
      import Folio.DSL
      import Folio.Sigil
      import Folio.Value
    end
  end

  @doc "Parse markdown into content nodes."
  @spec parse_markdown(String.t()) :: {:ok, [Folio.Content.t()]} | {:error, Folio.ParseError.t()}
  def parse_markdown(markdown) when is_binary(markdown) do
    wrap_call(fn -> Folio.Native.parse_markdown(markdown) end, Folio.ParseError)
  end

  @doc "Compile markdown or content to PDF bytes."
  @spec to_pdf(String.t() | [Folio.Content.t()], keyword()) ::
          {:ok, binary()} | {:error, Folio.CompileError.t()}
  def to_pdf(source, opts \\ [])

  def to_pdf(markdown, opts) when is_binary(markdown) do
    case parse_markdown(markdown) do
      {:ok, content} -> to_pdf(content, opts)
      {:error, _} = err -> err
    end
  end

  def to_pdf(content, opts) when is_list(content) do
    styles = Keyword.get(opts, :styles, [])
    wrap_call(fn -> Folio.Native.compile_pdf(content, styles) end, Folio.CompileError)
  end

  @doc "Compile markdown or content to SVG strings (one per page)."
  @spec to_svg(String.t() | [Folio.Content.t()], keyword()) ::
          {:ok, [String.t()]} | {:error, Folio.CompileError.t()}
  def to_svg(source, opts \\ [])

  def to_svg(markdown, opts) when is_binary(markdown) do
    case parse_markdown(markdown) do
      {:ok, content} -> to_svg(content, opts)
      {:error, _} = err -> err
    end
  end

  def to_svg(content, opts) when is_list(content) do
    styles = Keyword.get(opts, :styles, [])
    wrap_call(fn -> Folio.Native.compile_svg(content, styles) end, Folio.CompileError)
  end

  @doc "Compile markdown or content to PNG images (one per page)."
  @spec to_png(String.t() | [Folio.Content.t()], keyword()) ::
          {:ok, [binary()]} | {:error, Folio.CompileError.t()}
  def to_png(source, opts \\ [])

  def to_png(markdown, opts) when is_binary(markdown) do
    case parse_markdown(markdown) do
      {:ok, content} -> to_png(content, opts)
      {:error, _} = err -> err
    end
  end

  def to_png(content, opts) when is_list(content) do
    styles = Keyword.get(opts, :styles, [])
    wrap_call(fn -> Folio.Native.compile_png(content, styles) end, Folio.CompileError)
  end

  @doc "Register a file for use in documents (images, etc)."
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
