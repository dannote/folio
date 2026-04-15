defmodule Folio.Sigil do
  @moduledoc """
  The `~MD` sigil for writing Folio documents in Markdown.

  ## Modifiers

  - `~MD(...)"p"` — compile to PDF, returns `{:ok, binary()}`
  - `~MD(...)` — returns content nodes `[Folio.Content.t()]`

  ## Example

      use Folio

      {:ok, pdf} = ~MD("Generated on " <> to_string(Date.utc_today()), :p)
  """

  @doc false
  defmacro sigil_MD(term, modifiers) do
    format =
      case modifiers do
        ~c"p" -> :pdf
        _ -> :document
      end

    quote do
      Folio.Sigil.render(unquote(term), unquote(format))
    end
  end

  @doc false
  def render(markdown, :document) when is_binary(markdown) do
    Folio.parse_markdown(markdown)
  end

  def render(markdown, :pdf) when is_binary(markdown) do
    Folio.to_pdf(markdown)
  end
end
