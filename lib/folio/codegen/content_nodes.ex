defmodule Folio.Codegen.ContentNodes.Macros do
  @moduledoc false

  defmacro body_node(name) do
    quote do
      node unquote(name) do
        field(:body, {:vec, :content})
      end
    end
  end

  defmacro empty_node(name) do
    quote do
      node unquote(name) do
      end
    end
  end

  defmacro weak_node(name) do
    quote do
      node unquote(name) do
        field(:weak, :bool)
      end
    end
  end
end

defmodule Folio.Codegen.ContentNodes do
  @moduledoc false

  use RustQ.Rustler.Schema
  import Folio.Codegen.ContentNodes.Macros

  schema Folio.Content, rust_prefix: "Ex", tag_field: :__struct__ do
    type(:content, :ExContent)

    node Text do
      field(:text, :String)
      field(:size, {:option, :String})
      field(:weight, {:option, :String})
      field(:fill, {:option, :String})
      field(:tracking, {:option, :String})
    end

    empty_node(Space)

    node Heading do
      field(:body, {:vec, :content})
      field(:level, :u8)
    end

    body_node(Paragraph)

    body_node(Strong)

    body_node(Emph)

    body_node(Strike)

    body_node(Underline)

    node Highlight do
      field(:body, {:vec, :content})
      field(:fill, {:option, :String})
    end

    body_node(Super)

    body_node(Sub)

    body_node(Smallcaps)

    node Image do
      field(:src, :String)
      field(:width, {:option, :String})
      field(:height, {:option, :String})
      field(:fit, {:option, :String})
    end

    node Table do
      field(:columns, {:option, {:vec, :String}})
      field(:rows, {:option, :String})
      field(:children, {:vec, :content})
      field(:stroke, {:option, :String})
      field(:gutter, {:option, :String})
      field(:align, {:option, :String})
      field(:inset, {:option, :String})
      field(:fill, {:option, :String})
    end

    node TableHeader do
      field(:children, {:vec, :content})
    end

    node TableRow do
      field(:children, {:vec, :content})
    end

    node TableCell do
      field(:body, {:vec, :content})
      field(:colspan, {:option, :u32})
      field(:rowspan, {:option, :u32})
      field(:align, {:option, :String})
      field(:fill, {:option, :String})
      field(:stroke, {:option, :String})
    end

    node Math do
      field(:content, :String)
      field(:block, :bool)
    end

    node Link do
      field(:url, :String)
      field(:body, {:vec, :content})
    end

    node Raw do
      field(:text, :String)
      field(:lang, {:option, :String})
      field(:block, :bool)
    end

    node List do
      field(:children, {:vec, :content})
      field(:tight, :bool)
      field(:marker, {:option, :String})
    end

    body_node(ListItem)

    node Enum, module: "Folio.Content.EnumList" do
      field(:children, {:vec, :content})
      field(:tight, :bool)
      field(:start, {:option, :u32})
    end

    node EnumItem do
      field(:body, {:vec, :content})
      field(:number, {:option, :u32})
    end

    node Label do
      field(:name, :String)
    end

    node Ref do
      field(:target, :String)
      field(:supplement, {:option, {:vec, :content}})
    end

    node Align do
      field(:alignment, :String)
      field(:body, {:vec, :content})
    end

    body_node(Hide)

    body_node(Repeat)

    node Place do
      field(:alignment, {:option, :String})
      field(:body, {:vec, :content})
      field(:float, {:option, :bool})
    end

    node VSpace do
      field(:amount, :String)
      field(:weak, :bool)
    end

    node HSpace do
      field(:amount, :String)
      field(:weak, :bool)
    end

    node Pad do
      field(:body, {:vec, :content})
      field(:left, {:option, :String})
      field(:right, {:option, :String})
      field(:top, {:option, :String})
      field(:bottom, {:option, :String})
    end

    node Stack do
      field(:dir, :String)
      field(:children, {:vec, :content})
      field(:spacing, {:option, :String})
    end

    node Block do
      field(:body, {:vec, :content})
      field(:width, {:option, :String})
      field(:height, {:option, :String})
      field(:above, {:option, :String})
      field(:below, {:option, :String})
      field(:fill, {:option, :String})
      field(:inset, {:option, :String})
      field(:radius, {:option, :String})
      field(:stroke, {:option, :String})
    end

    node Rect do
      field(:body, {:vec, :content})
      field(:width, {:option, :String})
      field(:height, {:option, :String})
      field(:fill, {:option, :String})
      field(:inset, {:option, :String})
      field(:radius, {:option, :String})
    end

    node Square do
      field(:body, {:vec, :content})
      field(:size, {:option, :String})
      field(:fill, {:option, :String})
    end

    node Circle do
      field(:body, {:vec, :content})
      field(:radius, {:option, :String})
      field(:fill, {:option, :String})
    end

    node Ellipse do
      field(:body, {:vec, :content})
      field(:width, {:option, :String})
      field(:height, {:option, :String})
      field(:fill, {:option, :String})
    end

    node Line do
      field(:start, {:option, :String})
      field(:end, {:option, :String})
      field(:length, {:option, :String})
      field(:angle, {:option, :String})
      field(:stroke, {:option, :String})
    end

    node Polygon do
      field(:vertices, {:vec, :String})
      field(:fill, {:option, :String})
      field(:stroke, {:option, :String})
    end

    body_node(Title)

    body_node(Footnote)

    weak_node(Colbreak)

    weak_node(Pagebreak)

    empty_node(Parbreak)

    empty_node(Linebreak)

    empty_node(Divider)
  end
end
