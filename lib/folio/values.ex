defmodule Folio.Value do
  @moduledoc """
  Measurement unit constructors for layout values.

  All values are represented as tagged tuples that cross the NIF boundary.
  """

  @type t ::
          {:pt, number()}
          | {:cm, number()}
          | {:mm, number()}
          | {:em, number()}
          | {:fr, number()}
          | {:pct, number()}
          | {:deg, number()}
          | {:rgb, byte(), byte(), byte()}
          | {:luma, float()}
          | :auto
          | :none

  @doc "Points"
  @spec pt(number()) :: {:pt, number()}
  def pt(n), do: {:pt, n}

  @doc "Centimeters"
  @spec cm(number()) :: {:cm, number()}
  def cm(n), do: {:cm, n}

  @doc "Millimeters"
  @spec mm(number()) :: {:mm, number()}
  def mm(n), do: {:mm, n}

  @doc "Em (font-relative)"
  @spec em(number()) :: {:em, number()}
  def em(n), do: {:em, n}

  @doc "Fraction"
  @spec fr(number()) :: {:fr, number()}
  def fr(n), do: {:fr, n}

  @doc "Percentage"
  @spec pct(number()) :: {:pct, number()}
  def pct(n), do: {:pct, n}

  @doc "Degrees"
  @spec deg(number()) :: {:deg, number()}
  def deg(n), do: {:deg, n}

  @doc "RGB color"
  @spec rgb(byte(), byte(), byte()) :: {:rgb, byte(), byte(), byte()}
  def rgb(r, g, b), do: {:rgb, r, g, b}

  @doc "Luminance"
  @spec luma(float()) :: {:luma, float()}
  def luma(v), do: {:luma, v}
end
