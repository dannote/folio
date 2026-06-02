use RustQ.Config

require_file("lib/folio/codegen/content_schema.ex")

rust "native/folio_nif/src/generated_rustq_sample.rs" do
  Folio.Codegen.ContentSchema.rust_items()
end
