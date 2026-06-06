defmodule Folio.Codegen.ContentSchema do
  @moduledoc false

  use RustQ.Rustler.Schema

  schema Folio.Content, rust_prefix: "ExRustQ", tag_field: :__struct__ do
    default_attrs(["allow(dead_code)"])
    type(:content, :ExRustQContentSample)

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

    node Figure do
      field(:body, {:vec, :content})
      field(:caption, {:option, {:vec, :content}})
      field(:placement, {:option, :String})
      field(:scope, {:option, :String})
      field(:numbering, {:option, :String})
      field(:separator, {:option, :String})
    end

    node Quote do
      field(:body, {:vec, :content})
      field(:block, :bool)
      field(:attribution, {:option, {:vec, :content}})
    end

    node Grid do
      field(:columns, {:option, {:vec, :String}})
      field(:rows, {:option, {:vec, :String}})
      field(:gutter, {:option, :String})
      field(:column_gutter, {:option, :String})
      field(:row_gutter, {:option, :String})
      field(:children, {:vec, :content})
    end

    node GridCell do
      field(:body, {:vec, :content})
      field(:colspan, {:option, :u32})
      field(:rowspan, {:option, :u32})
      field(:align, {:option, :String})
      field(:fill, {:option, :String})
    end

    node LocalSet do
      field(:body, {:vec, :content})
      field(:hyphenate, {:option, :bool})
      field(:justify, {:option, :bool})
      field(:first_line_indent, {:option, :f64})
    end

    node RawTypst do
      field(:source, :String)
    end

    node Sequence do
      field(:children, {:vec, :content})
    end

    tagged_enum ContentSample do
      variants(:all)
      unknown(:unknown_content_variant)
    end
  end
end
