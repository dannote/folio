mod types;
mod convert;
mod mdex_bridge;
mod world;

use std::panic::AssertUnwindSafe;

use rustler::{Env, NifResult, OwnedBinary};

use world::FolioWorld;
use world as world_mod;
use types::{ExContent, ExStyle};

/// Wrap a NIF body in `catch_unwind` so Rust panics become structured
/// Rustler errors instead of crashing the BEAM.
fn catch_nif<F, T>(label: &str, f: F) -> NifResult<T>
where
    F: FnOnce() -> NifResult<T>,
{
    match std::panic::catch_unwind(AssertUnwindSafe(f)) {
        Ok(result) => result,
        Err(panic) => {
            let msg = match panic.downcast::<String>() {
                Ok(s) => format!("{} panicked: {}", label, *s),
                Err(p) => match p.downcast::<&str>() {
                    Ok(s) => format!("{} panicked: {}", label, *s),
                    Err(_) => format!("{} panicked with unknown value", label),
                },
            };
            Err(rustler::Error::RaiseTerm(Box::new(msg)))
        }
    }
}

#[rustler::nif(schedule = "DirtyCpu")]
fn parse_markdown(markdown: String) -> NifResult<Vec<ExContent>> {
    catch_nif("parse_markdown", || {
        let arena = typed_arena::Arena::new();
        let mut options = comrak::Options::default();
        options.extension.table = true;
        options.extension.strikethrough = true;
        options.extension.autolink = true;
        options.extension.math_dollars = true;

        let root = comrak::parse_document(&arena, &markdown, &options);
        Ok(mdex_bridge::convert_children(root))
    })
}

#[rustler::nif(schedule = "DirtyCpu")]
fn compile_pdf(
    env: Env<'_>,
    content: Vec<ExContent>,
    styles: Vec<ExStyle>,
) -> NifResult<rustler::Binary<'_>> {
    catch_nif("compile_pdf", || {
        let world = FolioWorld::new(styles);
        let bytes = world
            .compile_to_pdf(&content)
            .map_err(|msg| rustler::Error::RaiseTerm(Box::new(msg)))?;
        alloc_binary(env, &bytes)
    })
}

#[rustler::nif(schedule = "DirtyCpu")]
fn compile_svg(content: Vec<ExContent>, styles: Vec<ExStyle>) -> NifResult<Vec<String>> {
    catch_nif("compile_svg", || {
        let world = FolioWorld::new(styles);
        world
            .compile_to_svg(&content)
            .map_err(|msg| rustler::Error::RaiseTerm(Box::new(msg)))
    })
}

#[rustler::nif(schedule = "DirtyCpu")]
fn compile_png(
    env: Env<'_>,
    content: Vec<ExContent>,
    styles: Vec<ExStyle>,
) -> NifResult<Vec<rustler::Binary<'_>>> {
    catch_nif("compile_png", || {
        let world = FolioWorld::new(styles);
        let pages = world
            .compile_to_png(&content)
            .map_err(|msg| rustler::Error::RaiseTerm(Box::new(msg)))?;
        pages.iter().map(|b| alloc_binary(env, b)).collect()
    })
}

#[rustler::nif]
fn register_file(path: String, data: Vec<u8>) -> NifResult<String> {
    world_mod::register_file(path, data);
    Ok("ok".to_string())
}

fn alloc_binary<'a>(env: Env<'a>, bytes: &[u8]) -> NifResult<rustler::Binary<'a>> {
    let mut binary = OwnedBinary::new(bytes.len())
        .ok_or(rustler::Error::Term(Box::new("failed to allocate binary")))?;
    binary.as_mut_slice().copy_from_slice(bytes);
    Ok(binary.release(env))
}

rustler::init!("Elixir.Folio.Native");
