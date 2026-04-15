use std::sync::LazyLock;

use typst::diag::{FileError, FileResult};
use typst::engine::{Engine, Route, Sink, Traced};
use typst::foundations::{
    Bytes, Datetime, Duration, Smart, StyleChain, Styles, Target, TargetElem,
};
use typst::introspection::EmptyIntrospector;
use typst_layout::PagedDocument;
use typst::syntax::{FileId, RootedPath, Source, VirtualPath, VirtualRoot};
use typst::text::{Font, FontBook};
use typst::utils::LazyHash;
use typst::{Features, Library, LibraryExt, World};
use typst::comemo::Track;
use typst_layout::layout_document;
use typst_pdf::{PdfOptions, pdf};
use typst_svg::svg;
use typst_render::render;

use crate::types::ExContent;
use crate::convert::build_content;

struct GlobalState {
    library: LazyHash<Library>,
    fonts: Vec<Font>,
    book: LazyHash<FontBook>,
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
    GlobalState { library, fonts, book }
});

pub struct FolioWorld {
    main_id: FileId,
}

impl FolioWorld {
    pub fn new() -> Self {
        let main_id = RootedPath::new(
            VirtualRoot::Project,
            VirtualPath::new("main.typ").unwrap(),
        )
        .intern();
        Self { main_id }
    }

    fn layout(&self, content: &[ExContent]) -> Result<PagedDocument, String> {
        let body = build_content(content);

        let library = &GLOBAL.library;
        let base = StyleChain::new(&library.styles);
        let target_style: Styles = TargetElem::target.set(Target::Paged).wrap().into();
        let styles = base.chain(&target_style);

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

        layout_document(&mut engine, &body, styles)
            .map_err(|e| format!("Layout error: {:?}", e))
    }

    pub fn compile_to_pdf(&self, content: &[ExContent]) -> Result<Vec<u8>, String> {
        let doc = self.layout(content)?;

        let options = PdfOptions {
            ident: Smart::Auto,
            timestamp: None,
            page_ranges: None,
            standards: Default::default(),
            tagged: false,
        };

        pdf(&doc, &options).map_err(|e| format!("PDF export error: {:?}", e))
    }

    pub fn compile_to_svg(&self, content: &[ExContent]) -> Result<Vec<String>, String> {
        let doc = self.layout(content)?;
        Ok(doc.pages().iter().map(|page| svg(page)).collect())
    }

    pub fn compile_to_png(&self, content: &[ExContent]) -> Result<Vec<Vec<u8>>, String> {
        let doc = self.layout(content)?;
        let pixel_per_pt = 2.0;
        Ok(doc.pages().iter().map(|page| {
            let pixmap = render(page, pixel_per_pt);
            pixmap.encode_png()
                .unwrap_or_else(|_| Vec::new())
        }).collect())
    }
}

impl World for FolioWorld {
    fn library(&self) -> &LazyHash<Library> {
        &GLOBAL.library
    }

    fn book(&self) -> &LazyHash<FontBook> {
        &GLOBAL.book
    }

    fn main(&self) -> FileId {
        self.main_id
    }

    fn source(&self, id: FileId) -> FileResult<Source> {
        if id == self.main_id {
            Ok(Source::new(self.main_id, String::new()))
        } else {
            Err(FileError::NotFound(id.vpath().get_without_slash().into()))
        }
    }

    fn file(&self, id: FileId) -> FileResult<Bytes> {
        Err(FileError::NotFound(id.vpath().get_without_slash().into()))
    }

    fn font(&self, index: usize) -> Option<Font> {
        GLOBAL.fonts.get(index).cloned()
    }

    fn today(&self, _offset: Option<Duration>) -> Option<Datetime> {
        None
    }
}
