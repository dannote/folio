defmodule Folio.ParseError do
  @moduledoc "Error returned when Markdown parsing fails."

  @type t :: %__MODULE__{reason: String.t()}

  defexception [:reason]

  @impl true
  def message(%{reason: reason}), do: "Folio parse error: #{reason}"

  @doc "Create from a raw reason string."
  @spec new(String.t()) :: t()
  def new(reason) when is_binary(reason), do: %__MODULE__{reason: reason}
end
