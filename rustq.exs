use RustQ.Config

require_file("lib/folio/codegen/content_schema.ex")
require_file("lib/folio/codegen/content_nodes.ex")
require_file("lib/folio/codegen/native.ex")

generate :nifs, "native/folio_nif/src/generated_nifs.rs" do
  build(&Folio.Codegen.Native.rust_nifs/0)
end

rust "native/folio_nif/src/generated_content_nodes.rs" do
  Folio.Codegen.ContentNodes.rust_items()
end

rust "native/folio_nif/src/generated_rustq_sample.rs" do
  Folio.Codegen.ContentSchema.rust_items()
end
