defmodule Folio.ParseError do
  defexception [:reason]

  @impl true
  def message(%{reason: reason}), do: "Folio parse error: #{inspect(reason)}"
end
