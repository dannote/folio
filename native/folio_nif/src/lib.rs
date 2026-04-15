mod types;
mod convert;
mod mdex_bridge;
mod world;

use rustler::NifResult;

#[rustler::nif(schedule = "DirtyCpu")]
fn parse_markdown(markdown: String) -> NifResult<Vec<types::ExContent>> {
    let arena = typed_arena::Arena::new();
    let mut options = comrak::Options::default();
    options.extension.table = true;
    options.extension.strikethrough = true;
    options.extension.autolink = true;
    options.extension.math_dollars = true;

    let root = comrak::parse_document(&arena, &markdown, &options);
    let content = mdex_bridge::convert_children(root);

    Ok(content)
}

rustler::init!("Elixir.Folio.Native");
