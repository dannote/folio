defmodule Folio.Native do
  use Rustler,
    otp_app: :folio,
    crate: :folio_nif

  def parse_markdown(_markdown), do: exit(:nif_not_loaded)
  def compile(_document, _format), do: exit(:nif_not_loaded)
end
