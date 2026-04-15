defmodule Folio.Value do
  @moduledoc """
  Typed values that cross the NIF boundary.
  Maps to Typst's value system (units, colors, special values).
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
          | boolean()
          | integer()
          | float()
          | String.t()
          | [t()]
          | [{String.t() | atom(), t()}]

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

defprotocol Folio.Encoder do
  @doc "Convert an Elixir term to a Folio.Value"
  def encode(term)
end

defimpl Folio.Encoder, for: Atom do
  def encode(:auto), do: :auto
  def encode(:none), do: :none
  def encode(bool) when bool in [true, false], do: bool
  def encode(atom), do: Atom.to_string(atom)
end

defimpl Folio.Encoder, for: Integer do
  def encode(n), do: n
end

defimpl Folio.Encoder, for: Float do
  def encode(n), do: n
end

defimpl Folio.Encoder, for: BitString do
  def encode(s), do: s
end

defimpl Folio.Encoder, for: List do
  def encode(list), do: Enum.map(list, &Folio.Encoder.encode/1)
end
