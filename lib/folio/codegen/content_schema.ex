defmodule Folio.Codegen.ContentSchema do
  @moduledoc false

  use RustQ.Rustler.Schema

  schema Folio.Content, rust_prefix: "ExRustQ", tag_field: :__struct__ do
    default_attrs(["allow(dead_code)"])
    type(:content, :ExRustQContentSample)

    field_group :body_content do
      field(:body, {:vec, :content})
    end

    field_group :children_content do
      field(:children, {:vec, :content})
    end

    field_group :weak do
      field(:weak, :bool)
    end

    field_group :optional_size do
      field(:width, {:option, :String})
      field(:height, {:option, :String})
    end

    field_group :optional_fill do
      field(:fill, {:option, :String})
    end

    field_group :optional_stroke do
      field(:stroke, {:option, :String})
    end

    node Text do
      field(:text, :String)
      field(:size, {:option, :String})
      field(:weight, {:option, :String})
      fields(:optional_fill)
      field(:tracking, {:option, :String})
    end

    node Space do
    end

    node Heading do
      fields(:body_content)
      field(:level, :u8)
    end

    node Cite do
      field(:key, :String)
      field(:supplement, {:option, {:vec, :content}})
      field(:form, {:option, :String})
      field(:style, {:option, :String})
    end

    node Bibliography do
      field(:sources, {:vec, :String})
      field(:title, {:option, {:vec, :content}})
      field(:full, :bool)
      field(:style, {:option, :String})
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

    node Figure do
      fields(:body_content)
      field(:caption, {:option, {:vec, :content}})
      field(:placement, {:option, :String})
      field(:scope, {:option, :String})
      field(:numbering, {:option, :String})
      field(:separator, {:option, :String})
    end

    node Table do
      field(:columns, {:option, {:vec, :String}})
      field(:rows, {:option, :String})
      fields(:children_content)
      fields(:optional_stroke)
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
      field(:colspan, {:option, :u32})
      field(:rowspan, {:option, :u32})
      field(:align, {:option, :String})
      fields(:optional_fill)
      fields(:optional_stroke)
    end

    node Columns do
      field(:count, :u32)
      fields(:body_content)
      field(:gutter, {:option, :String})
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

    node Quote do
      fields(:body_content)
      field(:block, :bool)
      field(:attribution, {:option, {:vec, :content}})
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

    node Block do
      fields(:body_content)
      fields(:optional_size)
      field(:above, {:option, :String})
      field(:below, {:option, :String})
      fields(:optional_fill)
      field(:inset, {:option, :String})
      field(:radius, {:option, :String})
      fields(:optional_stroke)
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

    node Rect do
      fields(:body_content)
      fields(:optional_size)
      fields(:optional_fill)
      field(:inset, {:option, :String})
      field(:radius, {:option, :String})
    end

    node Square do
      fields(:body_content)
      field(:size, {:option, :String})
      fields(:optional_fill)
    end

    node Circle do
      fields(:body_content)
      field(:radius, {:option, :String})
      fields(:optional_fill)
    end

    node Ellipse do
      fields(:body_content)
      fields(:optional_size)
      fields(:optional_fill)
    end

    node Line do
      field(:start, {:option, :String})
      field(:end, {:option, :String})
      field(:length, {:option, :String})
      field(:angle, {:option, :String})
      fields(:optional_stroke)
    end

    node Polygon do
      field(:vertices, {:vec, :String})
      fields(:optional_fill)
      fields(:optional_stroke)
    end

    node Outline do
      field(:title, {:option, :String})
      field(:indent, {:option, :String})
      field(:depth, {:option, :u32})
    end

    node Title do
      fields(:body_content)
    end

    node TermList do
      fields(:children_content)
      field(:tight, :bool)
    end

    node TermItem do
      field(:term, {:vec, :content})
      field(:description, {:vec, :content})
    end

    node Footnote do
      fields(:body_content)
    end

    node Divider do
    end

    node Grid do
      field(:columns, {:option, {:vec, :String}})
      field(:rows, {:option, {:vec, :String}})
      field(:gutter, {:option, :String})
      field(:column_gutter, {:option, :String})
      field(:row_gutter, {:option, :String})
      fields(:children_content)
    end

    node GridCell do
      fields(:body_content)
      field(:colspan, {:option, :u32})
      field(:rowspan, {:option, :u32})
      field(:align, {:option, :String})
      fields(:optional_fill)
    end

    node LocalSet do
      fields(:body_content)
      field(:hyphenate, {:option, :bool})
      field(:justify, {:option, :bool})
      field(:first_line_indent, {:option, :f64})
    end

    node RawTypst do
      field(:source, :String)
    end

    node Sequence do
      fields(:children_content)
    end

    tagged_enum ContentSample do
      variants([
        :Text,
        :Space,
        :Heading,
        :Cite,
        :Bibliography,
        :Paragraph,
        :Strong,
        :Emph,
        :Strike,
        :Underline,
        :Highlight,
        :Super,
        :Sub,
        :Smallcaps,
        :Image,
        :Figure,
        :Table,
        :TableHeader,
        :TableRow,
        :TableCell,
        :Columns,
        :Colbreak,
        :Pagebreak,
        :Parbreak,
        :Linebreak,
        :Math,
        :Link,
        :Raw,
        :Quote,
        :List,
        :ListItem,
        :Enum,
        :EnumItem,
        :Label,
        :Ref,
        :Align,
        :Block,
        :Hide,
        :Repeat,
        :Place,
        :VSpace,
        :HSpace,
        :Pad,
        :Stack,
        :Rect,
        :Square,
        :Circle,
        :Ellipse,
        :Line,
        :Polygon,
        :Outline,
        :Title,
        :TermList,
        :TermItem,
        :Footnote,
        :Divider,
        :Grid,
        :GridCell,
        :LocalSet,
        :RawTypst,
        :Sequence
      ])

      unknown(:unknown_content_variant)
    end
  end
end
