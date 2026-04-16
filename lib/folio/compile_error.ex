defmodule Folio.CompileError do
  @moduledoc "Error returned when Folio compilation fails."

  @type t :: %__MODULE__{reason: String.t()}

  defexception [:reason]

  @impl true
  def message(%{reason: reason}), do: "Folio compile error: #{reason}"

  @doc "Create from a raw reason string."
  @spec new(String.t()) :: t()
  def new(reason) when is_binary(reason), do: %__MODULE__{reason: reason}
end
