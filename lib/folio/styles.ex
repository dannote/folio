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
    @moduledoc "Page dimensions in points. Fields: `width`, `height`."
    defstruct [:width, :height]
    @type t :: %__MODULE__{width: float() | nil, height: float() | nil}
  end

  defmodule PageMargin do
    @moduledoc "Page margins in points. Fields: `top`, `right`, `bottom`, `left`."
    defstruct [:top, :right, :bottom, :left]

    @type t :: %__MODULE__{
            top: float() | nil,
            right: float() | nil,
            bottom: float() | nil,
            left: float() | nil
          }
  end

  defmodule FontSize do
    @moduledoc "Base font size in points. Field: `size`."
    defstruct [:size]
    @type t :: %__MODULE__{size: float()}
  end

  defmodule FontFamily do
    @moduledoc "Font stack. Field: `families`."
    defstruct [:families]
    @type t :: %__MODULE__{families: [String.t()]}
  end

  defmodule FontWeight do
    @moduledoc "Font weight (100-900). Field: `weight`."
    defstruct [:weight]
    @type t :: %__MODULE__{weight: 100..900}
  end

  defmodule TextColor do
    @moduledoc "Text fill color (hex, named, rgb). Field: `color`."
    defstruct [:color]
    @type t :: %__MODULE__{color: String.t()}
  end

  defmodule ParJustify do
    @moduledoc "Enable justified paragraphs. Field: `justify`."
    defstruct [:justify]
    @type t :: %__MODULE__{justify: boolean()}
  end

  defmodule ParIndent do
    @moduledoc "First-line paragraph indent in points. Fields: `indent`, `all`."
    defstruct [:indent, :all]
    @type t :: %__MODULE__{indent: float(), all: boolean() | nil}
  end

  defmodule PageNumbering do
    @moduledoc """
    Page number format (e.g. `"1"`, `"i"`). Field: `pattern`.
    """
    defstruct [:pattern]
    @type t :: %__MODULE__{pattern: String.t()}
  end

  defmodule PageHeader do
    @moduledoc "Page header content. Field: `content`."
    defstruct [:content]
    @type t :: %__MODULE__{content: [Folio.Content.t()]}
  end

  defmodule PageFooter do
    @moduledoc "Page footer content. Field: `content`."
    defstruct [:content]
    @type t :: %__MODULE__{content: [Folio.Content.t()]}
  end

  defmodule HeadingNumbering do
    @moduledoc """
    Heading number format (e.g. `"1."`, `"A.1"`). Field: `pattern`.
    """
    defstruct [:pattern]
    @type t :: %__MODULE__{pattern: String.t()}
  end

  defmodule HeadingSupplement do
    @moduledoc """
    Heading supplement text (e.g. `"Chapter"`). Field: `content`.
    """
    defstruct [:content]
    @type t :: %__MODULE__{content: [Folio.Content.t()]}
  end

  defmodule HeadingOutlined do
    @moduledoc "Include heading in outline. Field: `outlined`."
    defstruct [:outlined]
    @type t :: %__MODULE__{outlined: boolean()}
  end

  defmodule HeadingBookmarked do
    @moduledoc "Include heading in PDF bookmarks. Field: `bookmarked`."
    defstruct [:bookmarked]
    @type t :: %__MODULE__{bookmarked: boolean()}
  end

  defmodule Lang do
    @moduledoc "Document language (ISO 639-1 code). Field: `lang`."
    defstruct [:lang]
    @type t :: %__MODULE__{lang: String.t()}
  end

  defmodule Hyphenate do
    @moduledoc "Enable/disable hyphenation. Field: `hyphenate`."
    defstruct [:hyphenate]
    @type t :: %__MODULE__{hyphenate: boolean()}
  end

  defmodule Leading do
    @moduledoc "Line leading in em units. Field: `leading`."
    defstruct [:leading]
    @type t :: %__MODULE__{leading: float()}
  end

  defmodule ParSpacing do
    @moduledoc "Paragraph spacing in em units. Field: `spacing`."
    defstruct [:spacing]
    @type t :: %__MODULE__{spacing: float()}
  end

  defmodule EnumIndent do
    @moduledoc "Enum list indent. Field: `indent`."
    defstruct [:indent]
    @type t :: %__MODULE__{indent: float()}
  end

  defmodule EnumBodyIndent do
    @moduledoc "Enum list body indent. Field: `body_indent`."
    defstruct [:body_indent]
    @type t :: %__MODULE__{body_indent: float()}
  end

  defmodule EnumItemSpacing do
    @moduledoc "Enum list item spacing in em. Field: `spacing`."
    defstruct [:spacing]
    @type t :: %__MODULE__{spacing: float()}
  end

  defmodule ListIndent do
    @moduledoc "Bullet list indent. Field: `indent`."
    defstruct [:indent]
    @type t :: %__MODULE__{indent: float()}
  end

  defmodule ListBodyIndent do
    @moduledoc "Bullet list body indent. Field: `body_indent`."
    defstruct [:body_indent]
    @type t :: %__MODULE__{body_indent: float()}
  end

  defmodule ListItemSpacing do
    @moduledoc "Bullet list item spacing in em. Field: `spacing`."
    defstruct [:spacing]
    @type t :: %__MODULE__{spacing: float()}
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
          | PageHeader.t()
          | PageFooter.t()
          | HeadingNumbering.t()
          | HeadingSupplement.t()
          | HeadingOutlined.t()
          | HeadingBookmarked.t()
          | Lang.t()
          | Hyphenate.t()
          | Leading.t()
          | ParSpacing.t()
          | EnumIndent.t()
          | EnumBodyIndent.t()
          | EnumItemSpacing.t()
          | ListIndent.t()
          | ListBodyIndent.t()
          | ListItemSpacing.t()

  @spec page_size(keyword()) :: PageSize.t()
  def page_size(opts) when is_list(opts) do
    %PageSize{width: Keyword.get(opts, :width), height: Keyword.get(opts, :height)}
  end

  @spec page_margin(keyword()) :: PageMargin.t()
  def page_margin(opts) when is_list(opts) do
    %PageMargin{
      top: Keyword.get(opts, :top),
      right: Keyword.get(opts, :right),
      bottom: Keyword.get(opts, :bottom),
      left: Keyword.get(opts, :left)
    }
  end

  @spec font_size(number()) :: FontSize.t()
  def font_size(size) when is_number(size), do: %FontSize{size: size / 1}

  @spec font_family([String.t()]) :: FontFamily.t()
  def font_family(families) when is_list(families), do: %FontFamily{families: families}

  @spec font_weight(100..900) :: FontWeight.t()
  def font_weight(weight) when is_integer(weight) and weight >= 100 and weight <= 900,
    do: %FontWeight{weight: weight}

  @spec text_color(String.t()) :: TextColor.t()
  def text_color(color) when is_binary(color), do: %TextColor{color: color}

  @spec par_justify(boolean()) :: ParJustify.t()
  def par_justify(justify) when is_boolean(justify), do: %ParJustify{justify: justify}

  @spec par_indent(number(), keyword()) :: ParIndent.t()
  def par_indent(indent, opts \\ []) when is_number(indent) do
    %ParIndent{indent: indent / 1, all: Keyword.get(opts, :all)}
  end

  @spec page_numbering(String.t()) :: PageNumbering.t()
  def page_numbering(pattern) when is_binary(pattern), do: %PageNumbering{pattern: pattern}

  @spec page_header(Folio.Content.t() | [Folio.Content.t()] | String.t()) :: PageHeader.t()
  def page_header(content), do: %PageHeader{content: Folio.Content.to_content(content)}

  @spec page_footer(Folio.Content.t() | [Folio.Content.t()] | String.t()) :: PageFooter.t()
  def page_footer(content), do: %PageFooter{content: Folio.Content.to_content(content)}

  @spec heading_numbering(String.t()) :: HeadingNumbering.t()
  def heading_numbering(pattern) when is_binary(pattern), do: %HeadingNumbering{pattern: pattern}

  @spec heading_supplement(Folio.Content.t() | [Folio.Content.t()] | String.t()) ::
          HeadingSupplement.t()
  def heading_supplement(content),
    do: %HeadingSupplement{content: Folio.Content.to_content(content)}

  @spec heading_outlined(boolean()) :: HeadingOutlined.t()
  def heading_outlined(outlined) when is_boolean(outlined),
    do: %HeadingOutlined{outlined: outlined}

  @spec heading_bookmarked(boolean()) :: HeadingBookmarked.t()
  def heading_bookmarked(bookmarked) when is_boolean(bookmarked),
    do: %HeadingBookmarked{bookmarked: bookmarked}

  @spec lang(String.t()) :: Lang.t()
  def lang(lang) when is_binary(lang), do: %Lang{lang: lang}

  @spec hyphenate(boolean()) :: Hyphenate.t()
  def hyphenate(hyphenate) when is_boolean(hyphenate), do: %Hyphenate{hyphenate: hyphenate}

  @spec leading(number()) :: Leading.t()
  def leading(leading) when is_number(leading), do: %Leading{leading: leading / 1}

  @spec par_spacing(number()) :: ParSpacing.t()
  def par_spacing(spacing) when is_number(spacing), do: %ParSpacing{spacing: spacing / 1}

  @spec enum_indent(number()) :: EnumIndent.t()
  def enum_indent(indent) when is_number(indent), do: %EnumIndent{indent: indent / 1}

  @spec enum_body_indent(number()) :: EnumBodyIndent.t()
  def enum_body_indent(body_indent) when is_number(body_indent),
    do: %EnumBodyIndent{body_indent: body_indent / 1}

  @spec enum_item_spacing(number()) :: EnumItemSpacing.t()
  def enum_item_spacing(spacing) when is_number(spacing),
    do: %EnumItemSpacing{spacing: spacing / 1}

  @spec list_indent(number()) :: ListIndent.t()
  def list_indent(indent) when is_number(indent), do: %ListIndent{indent: indent / 1}

  @spec list_body_indent(number()) :: ListBodyIndent.t()
  def list_body_indent(body_indent) when is_number(body_indent),
    do: %ListBodyIndent{body_indent: body_indent / 1}

  @spec list_item_spacing(number()) :: ListItemSpacing.t()
  def list_item_spacing(spacing) when is_number(spacing),
    do: %ListItemSpacing{spacing: spacing / 1}
end
