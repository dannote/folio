defmodule Folio.CompileError do
  defexception [:reason]

  @impl true
  def message(%{reason: reason}), do: "Folio compile error: #{inspect(reason)}"
end
