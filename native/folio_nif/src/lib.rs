mod types;
mod convert;
mod mdex_bridge;
mod world;

use rustler::{Env, NifResult, OwnedBinary};

use world::FolioWorld;
use types::ExContent;

#[rustler::nif(schedule = "DirtyCpu")]
fn parse_markdown(markdown: String) -> NifResult<Vec<ExContent>> {
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

#[rustler::nif(schedule = "DirtyCpu")]
fn compile_pdf(env: Env<'_>, content: Vec<ExContent>) -> NifResult<rustler::Binary<'_>> {
    let world = FolioWorld::new();
    match world.compile_to_pdf(&content) {
        Ok(bytes) => alloc_binary(env, &bytes),
        Err(msg) => Err(rustler::Error::RaiseTerm(Box::new(msg))),
    }
}

#[rustler::nif(schedule = "DirtyCpu")]
fn compile_svg(content: Vec<ExContent>) -> NifResult<Vec<String>> {
    let world = FolioWorld::new();
    match world.compile_to_svg(&content) {
        Ok(pages) => Ok(pages),
        Err(msg) => Err(rustler::Error::RaiseTerm(Box::new(msg))),
    }
}

#[rustler::nif(schedule = "DirtyCpu")]
fn compile_png(env: Env<'_>, content: Vec<ExContent>) -> NifResult<Vec<rustler::Binary<'_>>> {
    let world = FolioWorld::new();
    match world.compile_to_png(&content) {
        Ok(pages) => {
            let result: NifResult<Vec<rustler::Binary<'_>>> = pages
                .iter()
                .map(|bytes| alloc_binary(env, bytes))
                .collect();
            result
        }
        Err(msg) => Err(rustler::Error::RaiseTerm(Box::new(msg))),
    }
}

fn alloc_binary<'a>(env: Env<'a>, bytes: &[u8]) -> NifResult<rustler::Binary<'a>> {
    let mut binary = OwnedBinary::new(bytes.len())
        .ok_or(rustler::Error::Term(Box::new("failed to allocate binary")))?;
    binary.as_mut_slice().copy_from_slice(bytes);
    Ok(binary.release(env))
}

rustler::init!("Elixir.Folio.Native");
