defmodule Folio.Sigil do
  @moduledoc false

  @doc false
  defmacro sigil_MD(term, modifiers) do
    format =
      case modifiers do
        ~c"p" -> :pdf
        ~c"s" -> :svg
        _ -> :content
      end

    quote do
      Folio.Sigil.render(unquote(term), unquote(format))
    end
  end

  @doc false
  def render(markdown, :content) when is_binary(markdown) do
    Folio.parse_markdown(markdown)
  end

  def render(markdown, :pdf) when is_binary(markdown) do
    Folio.to_pdf(markdown)
  end

  def render(markdown, :svg) when is_binary(markdown) do
    Folio.to_svg(markdown)
  end
end
