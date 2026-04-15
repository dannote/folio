defmodule Folio.Native do
  use Rustler,
    otp_app: :folio,
    crate: :folio_nif

  def parse_markdown(_markdown), do: exit(:nif_not_loaded)
  def compile_pdf(_content), do: exit(:nif_not_loaded)
  def compile_svg(_content), do: exit(:nif_not_loaded)
  def compile_png(_content), do: exit(:nif_not_loaded)
end
