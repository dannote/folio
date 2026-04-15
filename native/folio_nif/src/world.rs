use std::collections::HashMap;
use std::str::FromStr;
use std::sync::{Arc, LazyLock, Mutex};

use typst::comemo::{Track, TrackedMut};
use typst::diag::{FileError, FileResult};
use typst::engine::{Engine, Route, Sink, Traced};
use typst::foundations::{
    Bytes, Content, Context, Datetime, Derived, Duration, NativeElement, Smart, StyleChain, Styles,
    Target, TargetElem,
};
use typst::introspection::EmptyIntrospector;
use typst::layout::{Abs, Margin, Sides};
use typst::layout::PageElem;
use typst::loading::{DataSource, LoadSource, Loaded};
use typst::math::EquationElem;
use typst::syntax::{FileId, RootedPath, Source, Span, Spanned, SyntaxMode, VirtualPath, VirtualRoot};
use typst::text::{Font, FontBook, TextElem, TextSize};
use typst::utils::LazyHash;
use typst::{Features, Library, LibraryExt, World};
use typst_layout::layout_document;
use typst_pdf::{PdfOptions, pdf};
use typst_svg::svg;
use typst_render::render;
use ecow::eco_format;

use crate::types::{ExContent, ExStyle};
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

static FILE_STORE: LazyLock<Arc<Mutex<HashMap<String, Vec<u8>>>>> =
    LazyLock::new(|| Arc::new(Mutex::new(HashMap::new())));

pub fn register_file(path: String, data: Vec<u8>) {
    FILE_STORE.lock().unwrap().insert(path, data);
}

pub struct FolioWorld {
    styles: Vec<ExStyle>,
}

impl FolioWorld {
    pub fn new(styles: Vec<ExStyle>) -> Self {
        Self { styles }
    }

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

    fn layout(&self, content: &[ExContent]) -> Result<typst_layout::PagedDocument, String> {
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

        // Clone the library and apply user styles
        let lib_styles = {
            let base_styles = &GLOBAL.library.styles;
            let mut s = base_styles.clone();
            apply_styles(&mut s, &self.styles);
            s
        };
        let base_lib: &Library = &GLOBAL.library;
        let lib = Library { styles: lib_styles, ..base_lib.clone() };
        let lib = LazyHash::new(lib);
        let base = StyleChain::new(&lib.styles);
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
            Ok(value) => match value.cast::<Content>() {
                Ok(content) => EquationElem::new(content).with_block(block).pack(),
                Err(_) => TextElem::packed(eco_format!("${}$", math_str)),
            },
            Err(_) => TextElem::packed(eco_format!("${}$", math_str)),
        }
    }

    pub fn get_image_source(src: &str) -> Option<Derived<DataSource, Loaded>> {
        let data = FILE_STORE.lock().unwrap().get(src).cloned()?;
        let bytes = Bytes::new(data);
        let loaded = Loaded::new(
            Spanned::new(LoadSource::Bytes, Span::detached()),
            bytes.clone(),
        );
        Some(Derived::new(DataSource::Bytes(bytes), loaded))
    }
}

fn apply_styles(styles: &mut typst::foundations::Styles, user_styles: &[ExStyle]) {
    for s in user_styles {
        match s {
            ExStyle::PageSize(sz) => {
                if let Some(w) = sz.width {
                    styles.set(PageElem::width, Smart::Custom(Abs::pt(w).into()));
                }
                if let Some(h) = sz.height {
                    styles.set(PageElem::height, Smart::Custom(Abs::pt(h).into()));
                }
            }
            ExStyle::PageMargin(m) => {
                let pt = |v: f64| Some(Smart::Custom(Abs::pt(v).into()));
                styles.set(PageElem::margin, Margin {
                    sides: Sides {
                        top: m.top.map_or_else(|| pt(70.866), pt),
                        right: m.right.map_or_else(|| pt(70.866), pt),
                        bottom: m.bottom.map_or_else(|| pt(70.866), pt),
                        left: m.left.map_or_else(|| pt(70.866), pt),
                    },
                    two_sided: None,
                });
            }
            ExStyle::FontSize(fs) => {
                styles.set(TextElem::size, TextSize(Abs::pt(fs.size).into()));
            }
            ExStyle::FontFamily(ff) => {
                let families: typst::text::FontList = typst::text::FontList(
                    ff.families.iter()
                        .map(|s| typst::text::FontFamily::new(s))
                        .collect());
                styles.set(TextElem::font, families);
            }
            ExStyle::FontWeight(fw) => {
                styles.set(TextElem::weight, typst::text::FontWeight::from_number(fw.weight));
            }
            ExStyle::TextColor(tc) => {
                if let Some(color) = crate::convert::parse_color(&tc.color) {
                    styles.set(TextElem::fill, typst::visualize::Paint::Solid(color));
                }
            }
            ExStyle::ParJustify(pj) => {
                styles.set(typst::model::ParElem::justify, pj.justify);
            }
            ExStyle::ParIndent(_pi) => {
                // ParIndent requires FirstLineIndent which has private fields.
                // TODO: implement when Typst exposes a constructor.
            }
            ExStyle::PageNumbering(pn) => {
                if let Ok(pat) = typst::model::NumberingPattern::from_str(&pn.pattern) {
                    styles.set(PageElem::numbering, Some(typst::model::Numbering::Pattern(pat)));
                }
            }
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
        let path = id.vpath().get_without_slash();
        let store = FILE_STORE.lock().unwrap();
        match store.get(path) {
            Some(data) => Ok(Bytes::new(data.clone())),
            None => Err(FileError::NotFound(path.into())),
        }
    }

    fn font(&self, index: usize) -> Option<Font> { GLOBAL.fonts.get(index).cloned() }
    fn today(&self, _offset: Option<Duration>) -> Option<Datetime> { None }
}
