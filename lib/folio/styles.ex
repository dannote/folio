defmodule Folio.Styles do
  @moduledoc """
  Style rules for customizing document appearance.

      Folio.to_pdf("# Hello", styles: [
        Folio.Styles.page_size(width: 595, height: 842),
        Folio.Styles.page_margin(top: 40, bottom: 40, left: 50, right: 50),
        Folio.Styles.font_size(11),
        Folio.Styles.font_family(["Helvetica", "Arial"]),
        Folio.Styles.text_color("#333333"),
      ])
  """

  defmodule PageSize do
    defstruct [:width, :height]
    @type t :: %__MODULE__{width: float() | nil, height: float() | nil}
  end

  defmodule PageMargin do
    defstruct [:top, :right, :bottom, :left]
    @type t :: %__MODULE__{top: float() | nil, right: float() | nil, bottom: float() | nil, left: float() | nil}
  end

  defmodule FontSize do
    defstruct [:size]
    @type t :: %__MODULE__{size: float()}
  end

  defmodule FontFamily do
    defstruct [:families]
    @type t :: %__MODULE__{families: [String.t()]}
  end

  defmodule FontWeight do
    defstruct [:weight]
    @type t :: %__MODULE__{weight: 100..900}
  end

  defmodule TextColor do
    defstruct [:color]
    @type t :: %__MODULE__{color: String.t()}
  end

  defmodule ParJustify do
    defstruct [:justify]
    @type t :: %__MODULE__{justify: boolean()}
  end

  defmodule ParIndent do
    defstruct [:indent]
    @type t :: %__MODULE__{indent: float()}
  end

  defmodule PageNumbering do
    defstruct [:pattern]
    @type t :: %__MODULE__{pattern: String.t()}
  end

  @type rule ::
          PageSize.t()
          | PageMargin.t()
          | FontSize.t()
          | FontFamily.t()
          | FontWeight.t()
          | TextColor.t()
          | ParJustify.t()
          | ParIndent.t()
          | PageNumbering.t()

  @spec page_size(keyword()) :: PageSize.t()
  def page_size(opts) when is_list(opts) do
    %PageSize{width: Keyword.get(opts, :width), height: Keyword.get(opts, :height)}
  end

  @spec page_margin(keyword()) :: PageMargin.t()
  def page_margin(opts) when is_list(opts) do
    %PageMargin{
      top: Keyword.get(opts, :top), right: Keyword.get(opts, :right),
      bottom: Keyword.get(opts, :bottom), left: Keyword.get(opts, :left),
    }
  end

  @spec font_size(number()) :: FontSize.t()
  def font_size(size) when is_number(size), do: %FontSize{size: size * 1.0}

  @spec font_family([String.t()]) :: FontFamily.t()
  def font_family(families) when is_list(families), do: %FontFamily{families: families}

  @spec font_weight(100..900) :: FontWeight.t()
  def font_weight(weight) when is_integer(weight) and weight >= 100 and weight <= 900, do: %FontWeight{weight: weight}

  @spec text_color(String.t()) :: TextColor.t()
  def text_color(color) when is_binary(color), do: %TextColor{color: color}

  @spec par_justify(boolean()) :: ParJustify.t()
  def par_justify(justify) when is_boolean(justify), do: %ParJustify{justify: justify}

  @spec par_indent(number()) :: ParIndent.t()
  def par_indent(indent) when is_number(indent), do: %ParIndent{indent: indent * 1.0}

  @spec page_numbering(String.t()) :: PageNumbering.t()
  def page_numbering(pattern) when is_binary(pattern), do: %PageNumbering{pattern: pattern}
end
