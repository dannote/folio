use std::sync::LazyLock;

use typst::comemo::{Track, TrackedMut};
use typst::diag::{FileError, FileResult};
use typst::engine::{Engine, Route, Sink, Traced};
use typst::foundations::{
    Bytes, Content, Context, Datetime, Duration, NativeElement, Smart, StyleChain, Styles,
    Target, TargetElem,
};
use typst::introspection::EmptyIntrospector;
use typst::math::EquationElem;
use typst::syntax::{FileId, RootedPath, Source, Span, SyntaxMode, VirtualPath, VirtualRoot};
use typst::text::{Font, FontBook, TextElem};
use typst::utils::LazyHash;
use typst::{Features, Library, LibraryExt, World};
use typst_layout::layout_document;
use typst_layout::PagedDocument;
use typst_pdf::{PdfOptions, pdf};
use typst_svg::svg;
use typst_render::render;
use ecow::eco_format;

use crate::types::ExContent;
use crate::convert::build_content;

struct GlobalState {
    library: LazyHash<Library>,
    fonts: Vec<Font>,
    book: LazyHash<FontBook>,
    main_id: FileId,
}

static GLOBAL: LazyLock<GlobalState> = LazyLock::new(|| {
    let fonts: Vec<Font> = typst_assets::fonts()
        .flat_map(|data| Font::iter(Bytes::new(data)))
        .collect();
    let book = LazyHash::new(FontBook::from_fonts(&fonts));
    let library = LazyHash::new(
        Library::builder()
            .with_features(Features::all())
            .build(),
    );
    let main_id = RootedPath::new(
        VirtualRoot::Project,
        VirtualPath::new("main.typ").unwrap(),
    )
    .intern();
    GlobalState { library, fonts, book, main_id }
});

pub struct FolioWorld;

impl FolioWorld {
    pub fn new() -> Self { Self }

    pub fn compile_to_pdf(&self, content: &[ExContent]) -> Result<Vec<u8>, String> {
        let doc = self.layout(content)?;
        pdf(&doc, &PdfOptions {
            ident: Smart::Auto,
            timestamp: None,
            page_ranges: None,
            standards: Default::default(),
            tagged: false,
        })
        .map_err(|e| format!("PDF export error: {:?}", e))
    }

    pub fn compile_to_svg(&self, content: &[ExContent]) -> Result<Vec<String>, String> {
        let doc = self.layout(content)?;
        Ok(doc.pages().iter().map(|p| svg(p)).collect())
    }

    pub fn compile_to_png(&self, content: &[ExContent]) -> Result<Vec<Vec<u8>>, String> {
        let doc = self.layout(content)?;
        Ok(doc.pages().iter().map(|p| render(p, 2.0).encode_png().unwrap_or_default()).collect())
    }

    fn layout(&self, content: &[ExContent]) -> Result<PagedDocument, String> {
        let mut sink = Sink::new();
        let introspector = EmptyIntrospector;
        let traced = Traced::default();

        let mut engine = Engine {
            routines: &typst::ROUTINES,
            world: Track::track(self),
            introspector: typst::utils::Protected::new(introspector.track()),
            traced: traced.track(),
            sink: sink.track_mut(),
            route: Route::root(),
        };

        let body = build_content(&mut engine, content);
        let base = StyleChain::new(&GLOBAL.library.styles);
        let target_style: Styles = TargetElem::target.set(Target::Paged).wrap().into();
        let styles = base.chain(&target_style);

        layout_document(&mut engine, &body, styles)
            .map_err(|e| format!("Layout error: {:?}", e))
    }

    pub fn eval_math(engine: &mut Engine, math_str: &str, block: bool) -> Content {
        let result = typst_eval::eval_string(
            engine.routines,
            engine.world,
            TrackedMut::reborrow_mut(&mut engine.sink),
            engine.introspector.into_raw(),
            Context::none().track(),
            math_str,
            Span::detached(),
            SyntaxMode::Math,
            typst::foundations::Scope::new(),
        );

        match result {
            Ok(value) => {
                match value.cast::<Content>() {
                    Ok(content) => EquationElem::new(content).with_block(block).pack(),
                    Err(_) => TextElem::packed(eco_format!("${}$", math_str)),
                }
            }
            Err(_) => TextElem::packed(eco_format!("${}$", math_str)),
        }
    }
}

impl World for FolioWorld {
    fn library(&self) -> &LazyHash<Library> { &GLOBAL.library }
    fn book(&self) -> &LazyHash<FontBook> { &GLOBAL.book }
    fn main(&self) -> FileId { GLOBAL.main_id }

    fn source(&self, id: FileId) -> FileResult<Source> {
        if id == GLOBAL.main_id {
            Ok(Source::new(GLOBAL.main_id, String::new()))
        } else {
            Err(FileError::NotFound(id.vpath().get_without_slash().into()))
        }
    }

    fn file(&self, id: FileId) -> FileResult<Bytes> {
        Err(FileError::NotFound(id.vpath().get_without_slash().into()))
    }

    fn font(&self, index: usize) -> Option<Font> { GLOBAL.fonts.get(index).cloned() }
    fn today(&self, _offset: Option<Duration>) -> Option<Datetime> { None }
}
