mod types;
mod convert;
mod mdex_bridge;
mod styles;
mod math;
mod world;

use rustler::{Env, NifResult, Term, Binary, ResourceArc};

use types::{ExDocument, ExContent};
use world::TypstexWorld;

rustler::init!("Elixir.Folio.Native", [compile, parse_markdown]);

fn compile<'a>(env: Env<'a>, doc: ExDocument, format: &str) -> NifResult<Term<'a>> {
    let world = world::create_world()?;

    let styles = styles::build_styles(&doc.styles);
    let content = convert::ex_sequence_to_content(&doc.content, &world);
    let styled = content.styled_with_map(styles);

    let library = typst::Library::default();
    let base = typst::foundations::StyleChain::new(&library.styles);

    // We need to go through typst's compile pipeline
    // but feeding Content directly instead of evaluating source.
    // The ROUTINES static handles dispatch.

    match format {
        "pdf" => {
            let paged = layout_document(&world, &styled, base)?;
            let pdf = typst_pdf::pdf(&paged, &typst_pdf::PdfOptions::default())
                .map_err(|e| rustler::Error::RaiseTerm(Box::new(format!("{:?}", e))))?;
            let mut buf = Binary::new(env, pdf.len());
            buf.copy_from_slice(&pdf);
            Ok(buf.encode(env))
        }
        "svg" => {
            let paged = layout_document(&world, &styled, base)?;
            let svgs: Vec<String> = paged.pages.iter()
                .map(|page| typst_svg::svg(page))
                .collect();
            Ok(svgs.encode(env))
        }
        "png" => {
            let paged = layout_document(&world, &styled, base)?;
            let pngs: Vec<Vec<u8>> = paged.pages.iter()
                .map(|page| typst_render::render(page, 2.0).encode_png().unwrap())
                .collect();
            let binaries: Vec<Binary> = pngs.into_iter()
                .map(|png| {
                    let mut buf = Binary::new(env, png.len());
                    buf.copy_from_slice(&png);
                    buf
                })
                .collect();
            Ok(binaries.encode(env))
        }
        _ => Err(rustler::Error::RaiseTerm(Box::new("unknown format"))),
    }
}

fn layout_document(
    world: &TypstexWorld,
    content: &typst::foundations::Content,
    base: typst::foundations::StyleChain,
) -> Result<typst_layout::PagedDocument, rustler::Error> {
    // Create engine and route
    let introspector = typst::introspection::EmptyIntrospector;
    let sink = typst::engine::Sink::new();
    let traced = typst::engine::Traced::default();

    let engine = typst::engine::Engine {
        routines: &typst::ROUTINES,
        world: world.track(),
        introspector: typst::utils::Protected::new(introspector.track()),
        traced: traced.track(),
        sink: sink.track_mut(),
        route: typst::engine::Route::default(),
    };

    let target = typst::layout::TargetElem::target.set(typst::layout::Target::Paged).wrap();
    let styles = base.chain(&target);

    typst_layout::layout_document(engine.world, content, styles)
        .map_err(|e| rustler::Error::RaiseTerm(Box::new(format!("{:?}", e))))
}

#[rustler::nif(schedule = "DirtyCpu")]
fn parse_markdown<'a>(env: Env<'a>, markdown: &str) -> NifResult<Term<'a>> {
    let arena = typed_arena::Arena::new();
    let options = comrak::Options::default();
    let root = comrak::parse_document(&arena, markdown, &options);

    let content: Vec<ExContent> = mdex_bridge::convert_children(root, &arena);

    Ok((rustler::atoms::ok(), content).encode(env))
}
