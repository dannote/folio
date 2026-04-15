defmodule Folio.ParseError do
  @moduledoc "Error returned when Markdown parsing fails."

  defexception [:message, :reason]

  @impl true
  def message(%{message: msg}), do: msg

  @doc "Create from a raw reason string."
  @spec new(String.t()) :: %__MODULE__{}
  def new(reason) when is_binary(reason) do
    %__MODULE__{message: "Folio parse error: #{reason}", reason: reason}
  end
end
