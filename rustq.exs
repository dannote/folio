import RustQ.Config

unless Code.ensure_loaded?(Folio.Codegen.ContentSchema) do
  Code.require_file("lib/folio/codegen/content_schema.ex")
end

rust_items "native/folio_nif/src/generated_rustq_sample.rs",
  items: Folio.Codegen.ContentSchema.rust_items()
