defmodule Folio.Sigil do
  @moduledoc """
  The `~MD` sigil for writing Folio documents in Markdown with embedded Elixir.

  ## Modifiers

  - `~MD"""..."""p` — compile to PDF, returns `binary()`
  - `~MD"""..."""s` — compile to SVG, returns `[binary()]`
  - `~MD"""..."""n` — compile to PNG, returns `[binary()]`
  - `~MD"""..."""` (no modifier) — returns `%Folio.Document{}`

  ## Interpolation

  `#{}` expressions can contain:
  - Any `Folio.Content.*` struct (from DSL functions)
  - A string (auto-wrapped as Text)
  - A list of content nodes
  - Elixir expressions (`for`, `if`, etc.)
  """

  @doc false
  defmacro sigil_MD(term, modifiers) do
    format =
      case modifiers do
        'p' -> :pdf
        's' -> :svg
        'n' -> :png
        _ -> :document
      end

    # The sigil content is a binary with interpolated expressions.
    # We pass it through to Folio.Native.parse_markdown at runtime
    # which uses comrak to parse, then merge in any DSL content.
    quote do
      Folio.Sigil.render(unquote(term), unquote(format))
    end
  end

  @doc false
  def render(markdown, format) when is_binary(markdown) do
    case Folio.Native.parse_markdown(markdown) do
      {:ok, content} ->
        doc = %Folio.Document{content: content, styles: []}

        case format do
          :document -> doc
          fmt -> Folio.Native.compile(doc, fmt)
        end

      {:error, reason} ->
        raise Folio.ParseError, reason: reason
    end
  end
end
