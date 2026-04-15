defmodule Folio.Native do
  @moduledoc false

  use Rustler,
    otp_app: :folio,
    crate: :folio_nif

  def parse_markdown(_markdown), do: exit(:nif_not_loaded)
  def compile_pdf(_content, _styles), do: exit(:nif_not_loaded)
  def compile_svg(_content, _styles), do: exit(:nif_not_loaded)
  def compile_png(_content, _styles), do: exit(:nif_not_loaded)
  def register_file(_path, _data), do: exit(:nif_not_loaded)
end
