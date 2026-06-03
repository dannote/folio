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

    node Title do
      fields(:body_content)
    end

    node Footnote do
      fields(:body_content)
    end

    node Parbreak do
    end

    node Linebreak do
    end

    node Divider do
    end
  end
end
