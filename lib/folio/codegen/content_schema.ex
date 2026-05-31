defmodule Folio.Codegen.ContentSchema do
  @moduledoc false

  use RustQ.Rustler.Schema

  schema Folio.Content, rust_prefix: "ExRustQ", tag_field: :__struct__ do
    default_attrs(["allow(dead_code)"])
    type(:content, :ExRustQContentSample)

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
      field(:body, {:vec, :content})
      field(:level, :u8)
    end

    node Paragraph do
      field(:body, {:vec, :content})
    end

    node Strong do
      field(:body, {:vec, :content})
    end

    node Image do
      field(:src, :String)
      field(:width, {:option, :String})
      field(:height, {:option, :String})
      field(:fit, {:option, :String})
    end

    node TableCell do
      field(:body, {:vec, :content})
      field(:colspan, {:option, :u32})
      field(:rowspan, {:option, :u32})
      field(:align, {:option, :String})
      field(:fill, {:option, :String})
      field(:stroke, {:option, :String})
    end

    tagged_enum ContentSample do
      variants([:Text, :Space, :Heading, :Paragraph, :Strong, :Image, :TableCell])
      unknown(:unknown_content_variant)
    end
  end
end
