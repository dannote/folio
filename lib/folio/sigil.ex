defmodule Folio.Sigil do
  @moduledoc """
  The `~MD` sigil for writing Folio documents in Markdown.

  ## Modifiers

  - `~MD(...)"p"` — compile to PDF, returns `binary()`
  - `~MD(...)` — returns content nodes `[Folio.Content.t()]`

  ## Example

      use Folio

      pdf = ~MD("Generated on " <> to_string(Date.utc_today()), :p)
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
  def render(markdown, format) when is_binary(markdown) do
    content = Folio.Native.parse_markdown(markdown)

    case format do
      :document -> content
      :pdf -> Folio.Native.compile_pdf(content, [])
    end
  end
end
