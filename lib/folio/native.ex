defmodule Folio.Native do
  @moduledoc false

  alias Folio.Content
  alias Folio.Styles

  use Rustler,
    otp_app: :folio,
    crate: :folio_nif

  @spec parse_markdown(String.t()) :: [Content.t()]
  def parse_markdown(_markdown), do: :erlang.nif_error(:nif_not_loaded)

  @spec compile_pdf([Content.t()], [Styles.rule()], %{String.t() => binary()}) :: binary()
  def compile_pdf(_content, _styles, _files), do: :erlang.nif_error(:nif_not_loaded)

  @spec compile_svg([Content.t()], [Styles.rule()], %{String.t() => binary()}) :: [String.t()]
  def compile_svg(_content, _styles, _files), do: :erlang.nif_error(:nif_not_loaded)

  @spec compile_png([Content.t()], [Styles.rule()], %{String.t() => binary()}, float()) :: [
          binary()
        ]
  def compile_png(_content, _styles, _files, _dpi), do: :erlang.nif_error(:nif_not_loaded)

  @spec register_file(String.t(), binary()) :: :ok
  def register_file(_path, _data), do: :erlang.nif_error(:nif_not_loaded)

  @spec unregister_file(String.t()) :: :ok
  def unregister_file(_path), do: :erlang.nif_error(:nif_not_loaded)
end
