defmodule Folio.Codegen.ContentNodes do
  @moduledoc false

  use RustQ.Rustler.Schema

  schema Folio.Content, rust_prefix: "Ex", tag_field: :__struct__ do
    field_group :body_content do
      field(:body, {:vec, :content})
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

    node Super do
      fields(:body_content)
    end

    node Sub do
      fields(:body_content)
    end

    node Smallcaps do
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
