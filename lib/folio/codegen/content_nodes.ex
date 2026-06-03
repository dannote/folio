defmodule Folio.Codegen.ContentNodes do
  @moduledoc false

  use RustQ.Rustler.Schema

  schema Folio.Content, rust_prefix: "Ex", tag_field: :__struct__ do
    field_group :body_content do
      field(:body, {:vec, :content})
    end

    field_group :optional_fill do
      field(:fill, {:option, :String})
    end

    field_group :optional_size do
      field(:width, {:option, :String})
      field(:height, {:option, :String})
    end

    field_group :weak do
      field(:weak, :bool)
    end

    field_group :children_content do
      field(:children, {:vec, :content})
    end

    field_group :table_span do
      field(:colspan, {:option, :u32})
      field(:rowspan, {:option, :u32})
    end

    type(:content, :ExContent)

    node Text do
      field(:text, :String)
      field(:size, {:option, :String})
      field(:weight, {:option, :String})
      field(:fill, {:option, :String})
      field(:tracking, {:option, :String})
    end

    node Space do
    end

    node Heading do
      fields(:body_content)
      field(:level, :u8)
    end

    node Paragraph do
      fields(:body_content)
    end

    node Strong do
      fields(:body_content)
    end

    node Emph do
      fields(:body_content)
    end

    node Strike do
      fields(:body_content)
    end

    node Underline do
      fields(:body_content)
    end

    node Highlight do
      fields(:body_content)
      fields(:optional_fill)
    end

    node Super do
      fields(:body_content)
    end

    node Sub do
      fields(:body_content)
    end

    node Smallcaps do
      fields(:body_content)
    end

    node Image do
      field(:src, :String)
      fields(:optional_size)
      field(:fit, {:option, :String})
    end

    node Table do
      field(:columns, {:option, {:vec, :String}})
      field(:rows, {:option, :String})
      fields(:children_content)
      field(:stroke, {:option, :String})
      field(:gutter, {:option, :String})
      field(:align, {:option, :String})
      field(:inset, {:option, :String})
      fields(:optional_fill)
    end

    node TableHeader do
      fields(:children_content)
    end

    node TableRow do
      fields(:children_content)
    end

    node TableCell do
      fields(:body_content)
      fields(:table_span)
      field(:align, {:option, :String})
      fields(:optional_fill)
      field(:stroke, {:option, :String})
    end

    node Math do
      field(:content, :String)
      field(:block, :bool)
    end

    node Link do
      field(:url, :String)
      fields(:body_content)
    end

    node Raw do
      field(:text, :String)
      field(:lang, {:option, :String})
      field(:block, :bool)
    end

    node List do
      fields(:children_content)
      field(:tight, :bool)
      field(:marker, {:option, :String})
    end

    node ListItem do
      fields(:body_content)
    end

    node Enum, module: "Folio.Content.EnumList" do
      fields(:children_content)
      field(:tight, :bool)
      field(:start, {:option, :u32})
    end

    node EnumItem do
      fields(:body_content)
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
      fields(:body_content)
    end

    node Hide do
      fields(:body_content)
    end

    node Repeat do
      fields(:body_content)
    end

    node Place do
      field(:alignment, {:option, :String})
      fields(:body_content)
      field(:float, {:option, :bool})
    end

    node VSpace do
      field(:amount, :String)
      fields(:weak)
    end

    node HSpace do
      field(:amount, :String)
      fields(:weak)
    end

    node Pad do
      fields(:body_content)
      field(:left, {:option, :String})
      field(:right, {:option, :String})
      field(:top, {:option, :String})
      field(:bottom, {:option, :String})
    end

    node Stack do
      field(:dir, :String)
      fields(:children_content)
      field(:spacing, {:option, :String})
    end

    node Title do
      fields(:body_content)
    end

    node Footnote do
      fields(:body_content)
    end

    node Colbreak do
      fields(:weak)
    end

    node Pagebreak do
      fields(:weak)
    end

    node Parbreak do
    end

    node Linebreak do
    end

    node Divider do
    end
  end
end
