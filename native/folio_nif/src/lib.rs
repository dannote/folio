mod types;
mod convert;
mod mdex_bridge;
mod world;

use std::panic::AssertUnwindSafe;

use rustler::{Env, NifResult, OwnedBinary};

rustler::atoms!(ok);

use world::FolioWorld;
use world as world_mod;
use types::{ExContent, ExStyle};

/// Wrap a NIF body in `catch_unwind` so Rust panics become structured
/// Rustler errors instead of crashing the BEAM.
///
/// # Safety
///
/// Typst's internal caches (comemo, etc.) are not unwind-safe. A panic
/// during compilation may leave the global file store or comemo caches
/// in an inconsistent state, potentially corrupting subsequent compilations.
/// If a panic occurs, restarting the BEAM VM is the only fully safe recovery.
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
fn compile_pdf<'a>(
    env: Env<'a>,
    content: Vec<ExContent>,
    styles: Vec<ExStyle>,
    files: std::collections::HashMap<String, rustler::Binary<'a>>,
) -> NifResult<rustler::Binary<'a>> {
    catch_nif("compile_pdf", || {
        let session_files = decode_file_map(files);
        let world = FolioWorld::new(styles, session_files);
        let result = world
            .compile_to_pdf(&content)
            .map_err(|msg| rustler::Error::RaiseTerm(Box::new(msg)));
        world_mod::clear_session_files();
        let bytes = result?;
        alloc_binary(env, &bytes)
    })
}

#[rustler::nif(schedule = "DirtyCpu")]
fn compile_svg<'a>(
    content: Vec<ExContent>,
    styles: Vec<ExStyle>,
    files: std::collections::HashMap<String, rustler::Binary<'a>>,
) -> NifResult<Vec<String>> {
    catch_nif("compile_svg", || {
        let session_files = decode_file_map(files);
        let world = FolioWorld::new(styles, session_files);
        let result = world
            .compile_to_svg(&content)
            .map_err(|msg| rustler::Error::RaiseTerm(Box::new(msg)));
        world_mod::clear_session_files();
        result
    })
}

/// Compile to PNG. Each page is rendered and encoded independently so peak
/// memory is proportional to the largest page, not the total document.
/// `dpi` is the render scale factor (1.0 = 72 DPI, 2.0 = 144 DPI, etc.).
#[rustler::nif(schedule = "DirtyCpu")]
fn compile_png<'a>(
    env: Env<'a>,
    content: Vec<ExContent>,
    styles: Vec<ExStyle>,
    files: std::collections::HashMap<String, rustler::Binary<'a>>,
    dpi: f64,
) -> NifResult<Vec<rustler::Binary<'a>>> {
    catch_nif("compile_png", || {
        let session_files = decode_file_map(files);
        let world = FolioWorld::new(styles, session_files);
        let result = world
            .compile_to_png(&content, dpi)
            .map_err(|msg| rustler::Error::RaiseTerm(Box::new(msg)));
        world_mod::clear_session_files();
        let pages = result?;
        pages.iter().map(|b| alloc_binary(env, b)).collect()
    })
}

#[rustler::nif]
fn register_file(path: String, data: rustler::Binary) -> rustler::Atom {
    world_mod::register_file(path, data.as_slice().to_vec());
    ok()
}

#[rustler::nif]
fn unregister_file(path: String) -> rustler::Atom {
    world_mod::unregister_file(path);
    ok()
}

fn decode_file_map(files: std::collections::HashMap<String, rustler::Binary<'_>>) -> std::collections::HashMap<String, Vec<u8>> {
    files.into_iter().map(|(k, v)| (k, v.as_slice().to_vec())).collect()
}

fn alloc_binary<'a>(env: Env<'a>, bytes: &[u8]) -> NifResult<rustler::Binary<'a>> {
    let mut binary = OwnedBinary::new(bytes.len())
        .ok_or(rustler::Error::Term(Box::new("failed to allocate binary")))?;
    binary.as_mut_slice().copy_from_slice(bytes);
    Ok(binary.release(env))
}

rustler::init!("Elixir.Folio.Native");
