use std::cell::RefCell;
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

use crate::convert::build_content;
use crate::types::{ExContent, ExStyle};
use typst::model::{HeadingElem, Numbering, NumberingPattern, Supplement};

struct GlobalState {
    library: LazyHash<Library>,
    fonts: Vec<Font>,
    book: LazyHash<FontBook>,
    main_id: FileId,
}

fn load_system_fonts() -> Vec<Font> {
    let mut db = fontdb::Database::new();
    db.load_system_fonts();

    let mut fonts = Vec::new();
    for face in db.faces() {
        let _ = db.with_face_data(face.id, |data, index| {
            let bytes = Bytes::new(data.to_vec());
            for font in Font::iter(bytes) {
                if font.index() == index {
                    fonts.push(font);
                }
            }
        });
    }
    fonts
}

static GLOBAL: LazyLock<GlobalState> = LazyLock::new(|| {
    let mut fonts: Vec<Font> = typst_assets::fonts()
        .flat_map(|data| Font::iter(Bytes::new(data)))
        .collect();
    fonts.extend(load_system_fonts());
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

type FileStore = Arc<Mutex<HashMap<String, Vec<u8>>>>;

/// Global fallback file store for `register_file`/`unregister_file`.
static GLOBAL_FILE_STORE: LazyLock<FileStore> =
    LazyLock::new(|| Arc::new(Mutex::new(HashMap::new())));

pub fn register_file(path: String, data: Vec<u8>) {
    GLOBAL_FILE_STORE.lock().unwrap().insert(path, data);
}

pub fn unregister_file(path: String) {
    GLOBAL_FILE_STORE.lock().unwrap().remove(&path);
}

thread_local! {
    static SESSION_FILES: RefCell<HashMap<String, Vec<u8>>> = RefCell::new(HashMap::new());
}

pub fn set_session_files(files: HashMap<String, Vec<u8>>) {
    SESSION_FILES.with(|cell| *cell.borrow_mut() = files);
}

pub fn clear_session_files() {
    SESSION_FILES.with(|cell| cell.borrow_mut().clear());
}

/// Look up file data: session files first, then global store.
pub fn get_file_data(src: &str) -> Option<Vec<u8>> {
    SESSION_FILES.with(|cell| {
        if let Some(data) = cell.borrow().get(src) {
            return Some(data.clone());
        }
        None
    }).or_else(|| GLOBAL_FILE_STORE.lock().unwrap().get(src).cloned())
}

pub struct FolioWorld {
    styles: Vec<ExStyle>,
}

impl FolioWorld {
    pub fn new(styles: Vec<ExStyle>, session_files: HashMap<String, Vec<u8>>) -> Self {
        set_session_files(session_files);
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
        Ok(doc.pages().iter().map(svg).collect())
    }

    /// Render each page to PNG at the given DPI scale.
    /// Peak memory is proportional to the largest page, not the total document.
    pub fn compile_to_png(&self, content: &[ExContent], dpi: f64) -> Result<Vec<Vec<u8>>, String> {
        let scale = if dpi <= 0.0 { 2.0 } else { dpi };
        let doc = self.layout(content)?;
        doc.pages().iter().map(|p| {
            render(p, scale as f32).encode_png().map_err(|e| format!("PNG encode error: {:?}", e))
        }).collect()
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

        let lib = &GLOBAL.library;
        let base = StyleChain::new(&lib.styles);
        let mut user_styles = typst::foundations::Styles::new();
        apply_styles(&mut user_styles, &self.styles, &mut engine);
        let target_style: Styles = TargetElem::target.set(Target::Paged).wrap().into();
        let chained = base.chain(&target_style);
        let styles = chained.chain(&user_styles);

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
}

pub(crate) fn get_image_source(src: &str) -> Option<Derived<DataSource, Loaded>> {
    let data = get_file_data(src)?;
    let bytes = Bytes::new(data);
    let loaded = Loaded::new(
        Spanned::new(LoadSource::Bytes, Span::detached()),
        bytes.clone(),
    );
    Some(Derived::new(DataSource::Bytes(bytes), loaded))
}

fn style_content(engine: &mut Engine, nodes: &[ExContent]) -> Content {
    build_content(engine, nodes)
}

fn apply_styles(styles: &mut typst::foundations::Styles, user_styles: &[ExStyle], engine: &mut Engine) {
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
                let side = |v: Option<f64>| v.map(|x| Smart::Custom(Abs::pt(x).into()));
                if m.top.is_none() && m.right.is_none() && m.bottom.is_none() && m.left.is_none() {
                } else {
                    styles.set(PageElem::margin, Margin {
                        sides: Sides {
                            top: side(m.top),
                            right: side(m.right),
                            bottom: side(m.bottom),
                            left: side(m.left),
                        },
                        two_sided: None,
                    });
                }
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
            ExStyle::ParIndent(pi) => {
                let fli = typst::model::FirstLineIndent::new(
                    Some(Abs::pt(pi.indent).into()),
                    pi.all.map(|a| if a { Some(true) } else { None }).flatten(),
                );
                styles.set(typst::model::ParElem::first_line_indent, fli);
            }
            ExStyle::PageNumbering(pn) => {
                if let Ok(pat) = NumberingPattern::from_str(&pn.pattern) {
                    styles.set(PageElem::numbering, Some(Numbering::Pattern(pat)));
                }
            }
            ExStyle::PageHeader(ph) => {
                styles.set(PageElem::header, Smart::Custom(Some(style_content(engine, &ph.content))));
            }
            ExStyle::PageFooter(pf) => {
                styles.set(PageElem::footer, Smart::Custom(Some(style_content(engine, &pf.content))));
            }
            ExStyle::HeadingNumbering(hn) => {
                if let Ok(pat) = NumberingPattern::from_str(&hn.pattern) {
                    styles.set(HeadingElem::numbering, Some(Numbering::Pattern(pat)));
                }
            }
            ExStyle::HeadingSupplement(hs) => {
                styles.set(
                    HeadingElem::supplement,
                    Smart::Custom(Some(Supplement::Content(style_content(engine, &hs.content)))),
                );
            }
            ExStyle::HeadingOutlined(ho) => {
                styles.set(HeadingElem::outlined, ho.outlined);
            }
            ExStyle::HeadingBookmarked(hb) => {
                styles.set(HeadingElem::bookmarked, Smart::Custom(hb.bookmarked));
            }
            ExStyle::Lang(l) => {
                if let Ok(lang) = std::str::FromStr::from_str(&l.lang) {
                    styles.set(TextElem::lang, lang);
                }
            }
            ExStyle::Hyphenate(h) => {
                styles.set(TextElem::hyphenate, Smart::Custom(h.hyphenate));
            }
            ExStyle::Leading(l) => {
                styles.set(
                    typst::model::ParElem::leading,
                    typst::layout::Length { abs: Abs::zero(), em: typst::layout::Em::new(l.leading) },
                );
            }
            ExStyle::ParSpacing(s) => {
                styles.set(
                    typst::model::ParElem::spacing,
                    typst::layout::Length { abs: Abs::zero(), em: typst::layout::Em::new(s.spacing) },
                );
            }
            ExStyle::EnumIndent(e) => {
                styles.set(
                    typst::model::EnumElem::indent,
                    typst::layout::Length { abs: Abs::pt(e.indent), em: typst::layout::Em::zero() },
                );
            }
            ExStyle::EnumBodyIndent(e) => {
                styles.set(
                    typst::model::EnumElem::body_indent,
                    typst::layout::Length { abs: Abs::pt(e.body_indent), em: typst::layout::Em::zero() },
                );
            }
            ExStyle::EnumItemSpacing(e) => {
                styles.set(
                    typst::model::EnumElem::spacing,
                    Smart::Custom(typst::layout::Length { abs: Abs::zero(), em: typst::layout::Em::new(e.spacing) }),
                );
            }
            ExStyle::ListIndent(l) => {
                styles.set(
                    typst::model::ListElem::indent,
                    typst::layout::Length { abs: Abs::pt(l.indent), em: typst::layout::Em::zero() },
                );
            }
            ExStyle::ListBodyIndent(l) => {
                styles.set(
                    typst::model::ListElem::body_indent,
                    typst::layout::Length { abs: Abs::pt(l.body_indent), em: typst::layout::Em::zero() },
                );
            }
            ExStyle::ListItemSpacing(l) => {
                styles.set(
                    typst::model::ListElem::spacing,
                    Smart::Custom(typst::layout::Length { abs: Abs::zero(), em: typst::layout::Em::new(l.spacing) }),
                );
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
        match get_file_data(path) {
            Some(data) => Ok(Bytes::new(data)),
            None => Err(FileError::NotFound(path.into())),
        }
    }

    fn font(&self, index: usize) -> Option<Font> { GLOBAL.fonts.get(index).cloned() }
    fn today(&self, _offset: Option<Duration>) -> Option<Datetime> { None }
}
