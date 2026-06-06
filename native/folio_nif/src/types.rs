use rustler::{NifStruct, NifUntaggedEnum};

// --- Content Nodes ---

rustler::atoms! {
    atom_struct = "__struct__",
}

include!("generated_content_nodes.rs");

// --- Styles ---

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Styles.PageSize"]
pub struct ExPageSize { pub width: Option<f64>, pub height: Option<f64> }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Styles.PageMargin"]
pub struct ExPageMargin {
    pub top: Option<f64>, pub right: Option<f64>,
    pub bottom: Option<f64>, pub left: Option<f64>,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Styles.FontSize"]
pub struct ExFontSize { pub size: f64 }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Styles.FontFamily"]
pub struct ExFontFamily { pub families: Vec<String> }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Styles.FontWeight"]
pub struct ExFontWeight { pub weight: u16 }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Styles.TextColor"]
pub struct ExTextColor { pub color: String }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Styles.ParJustify"]
pub struct ExParJustify { pub justify: bool }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Styles.ParIndent"]
pub struct ExParIndent { pub indent: f64, pub all: Option<bool> }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Styles.PageNumbering"]
pub struct ExPageNumbering { pub pattern: String }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Styles.PageHeader"]
pub struct ExPageHeader { pub content: Vec<ExContent> }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Styles.PageFooter"]
pub struct ExPageFooter { pub content: Vec<ExContent> }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Styles.HeadingNumbering"]
pub struct ExHeadingNumbering { pub pattern: String }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Styles.HeadingSupplement"]
pub struct ExHeadingSupplement { pub content: Vec<ExContent> }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Styles.HeadingOutlined"]
pub struct ExHeadingOutlined { pub outlined: bool }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Styles.HeadingBookmarked"]
pub struct ExHeadingBookmarked { pub bookmarked: bool }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Styles.Lang"]
pub struct ExLang { pub lang: String }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Styles.Hyphenate"]
pub struct ExHyphenate { pub hyphenate: bool }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Styles.Leading"]
pub struct ExLeading { pub leading: f64 }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Styles.ParSpacing"]
pub struct ExParSpacing { pub spacing: f64 }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Styles.EnumIndent"]
pub struct ExEnumIndent { pub indent: f64 }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Styles.EnumBodyIndent"]
pub struct ExEnumBodyIndent { pub body_indent: f64 }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Styles.EnumItemSpacing"]
pub struct ExEnumItemSpacing { pub spacing: f64 }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Styles.ListIndent"]
pub struct ExListIndent { pub indent: f64 }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Styles.ListBodyIndent"]
pub struct ExListBodyIndent { pub body_indent: f64 }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Styles.ListItemSpacing"]
pub struct ExListItemSpacing { pub spacing: f64 }

#[derive(Clone, Debug, NifUntaggedEnum)]
pub enum ExStyle {
    PageSize(ExPageSize),
    PageMargin(ExPageMargin),
    FontSize(ExFontSize),
    FontFamily(ExFontFamily),
    FontWeight(ExFontWeight),
    TextColor(ExTextColor),
    ParJustify(ExParJustify),
    ParIndent(ExParIndent),
    PageNumbering(ExPageNumbering),
    PageHeader(ExPageHeader),
    PageFooter(ExPageFooter),
    HeadingNumbering(ExHeadingNumbering),
    HeadingSupplement(ExHeadingSupplement),
    HeadingOutlined(ExHeadingOutlined),
    HeadingBookmarked(ExHeadingBookmarked),
    Lang(ExLang),
    Hyphenate(ExHyphenate),
    Leading(ExLeading),
    ParSpacing(ExParSpacing),
    EnumIndent(ExEnumIndent),
    EnumBodyIndent(ExEnumBodyIndent),
    EnumItemSpacing(ExEnumItemSpacing),
    ListIndent(ExListIndent),
    ListBodyIndent(ExListBodyIndent),
    ListItemSpacing(ExListItemSpacing),
}
