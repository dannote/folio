defmodule Folio.Styles do
  @moduledoc """
  Style rules for customizing document appearance.

      Folio.to_pdf("# Hello", styles: [
        Folio.Styles.page_size(width: 595, height: 842),
        Folio.Styles.page_margin(top: 40, bottom: 40, left: 50, right: 50),
        Folio.Styles.font_size(11)
      ])
  """

  defmodule PageSize do
    @moduledoc "Set page dimensions in points."
    defstruct [:width, :height]
    @type t :: %__MODULE__{width: float() | nil, height: float() | nil}
  end

  defmodule PageMargin do
    @moduledoc "Set page margins in points."
    defstruct [:top, :right, :bottom, :left]
    @type t :: %__MODULE__{
      top: float() | nil,
      right: float() | nil,
      bottom: float() | nil,
      left: float() | nil
    }
  end

  defmodule FontSize do
    @moduledoc "Set base font size in points."
    defstruct [:size]
    @type t :: %__MODULE__{size: float()}
  end

  @type rule :: PageSize.t() | PageMargin.t() | FontSize.t()

  @doc "Set page dimensions in points."
  @spec page_size(keyword()) :: PageSize.t()
  def page_size(opts) when is_list(opts) do
    %PageSize{width: Keyword.get(opts, :width), height: Keyword.get(opts, :height)}
  end

  @doc "Set page margins in points."
  @spec page_margin(keyword()) :: PageMargin.t()
  def page_margin(opts) when is_list(opts) do
    %PageMargin{
      top: Keyword.get(opts, :top),
      right: Keyword.get(opts, :right),
      bottom: Keyword.get(opts, :bottom),
      left: Keyword.get(opts, :left)
    }
  end

  @doc "Set base font size in points."
  @spec font_size(number()) :: FontSize.t()
  def font_size(size) when is_number(size), do: %FontSize{size: size * 1.0}
end
