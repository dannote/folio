use std::sync::Arc;
use std::path::PathBuf;

use comemo::{Tracked, Track};
use ecow::EcoVec;
use parking_lot::Mutex;
use rustler::NifResult;
use typst::foundations::{Bytes, Datetime, LazyHash};
use typst::layout::Abs;
use typst::text::{Font, FontBook};
use typst::utils::LazyHash as TypstLazyHash;
use typst::World;
use typst_library::Library;

/// Shared world state that can be tracked by comemo.
pub struct TypstexWorld {
    library: LazyHash<Library>,
    book: LazyHash<FontBook>,
    fonts: Vec<Font>,
}

impl TypstexWorld {
    pub fn new() -> Result<Self, Box<dyn std::error::Error>> {
        // Load embedded fonts from typst-assets
        let fonts: Vec<Font> = typst_assets::fonts()
            .iter()
            .filter_map(|data| Font::new(Bytes::from_static(data), 0))
            .collect();

        let book = FontBook::from_fonts(&fonts);
        let library = Library::default();

        Ok(Self {
            library: LazyHash::new(library),
            book: LazyHash::new(book),
            fonts,
        })
    }

    pub fn track(&self) -> Tracked<dyn World + '_> {
        // comemo tracking
        todo!("implement comemo tracking")
    }

    pub fn get_font(&self, index: usize) -> Option<&Font> {
        self.fonts.get(index)
    }
}

impl World for TypstexWorld {
    fn library(&self) -> &LazyHash<Library> {
        &self.library
    }

    fn book(&self) -> &LazyHash<FontBook> {
        &self.book
    }

    fn main(&self) -> typst_syntax::FileId {
        typst_syntax::FileId::new(None, typst_syntax::VirtualPath::new("main.typ"))
    }

    fn source(&self, id: typst_syntax::FileId) -> Result<typst_syntax::Source, typst::diag::FileError> {
        // We don't use source files — all content is constructed programmatically
        Err(typst::diag::FileError::NotFound(id.vpath().as_rooted_path().to_path_buf()))
    }

    fn file(&self, id: typst_syntax::FileId) -> Result<Bytes, typst::diag::FileError> {
        // TODO: implement file loading for images, bibliography files, etc.
        Err(typst::diag::FileError::NotFound(id.vpath().as_rooted_path().to_path_buf()))
    }

    fn font(&self, index: usize) -> Option<Font> {
        self.fonts.get(index).cloned()
    }

    fn today(&self, offset: Option<std::time::Duration>) -> Option<Datetime> {
        None
    }
}

pub fn create_world() -> Result<TypstexWorld, rustler::Error> {
    TypstexWorld::new().map_err(|e| rustler::Error::RaiseTerm(Box::new(format!("{}", e))))
}
