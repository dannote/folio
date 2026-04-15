use rustler::{NifStruct, NifEnum, NifUntaggedEnum, NifUnitEnum};
use ecow::EcoString;

// --- Content Nodes ---

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Text"]
pub struct ExText {
    pub text: String,
}

#[derive(Clone, Debug)]
pub struct ExSpace;

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Heading"]
pub struct ExHeading {
    pub body: Vec<ExContent>,
    pub level: u8,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Paragraph"]
pub struct ExParagraph {
    pub body: Vec<ExContent>,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Strong"]
pub struct ExStrong {
    pub body: Vec<ExContent>,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Emph"]
pub struct ExEmph {
    pub body: Vec<ExContent>,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Image"]
pub struct ExImage {
    pub src: String,
    pub width: Option<ExValue>,
    pub height: Option<ExValue>,
    pub fit: Option<String>,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Figure"]
pub struct ExFigure {
    pub body: Vec<ExContent>,
    pub caption: Option<Vec<ExContent>>,
    pub placement: Option<String>,
    pub scope: Option<String>,
    pub numbering: Option<String>,
    pub separator: Option<String>,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Table"]
pub struct ExTable {
    pub columns: Vec<ExValue>,
    pub rows: Vec<ExValue>,
    pub children: Vec<ExContent>,
    pub stroke: Option<ExValue>,
    pub gutter: Option<ExValue>,
    pub align: Option<String>,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.TableHeader"]
pub struct ExTableHeader {
    pub children: Vec<ExContent>,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.TableRow"]
pub struct ExTableRow {
    pub children: Vec<ExContent>,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.TableCell"]
pub struct ExTableCell {
    pub body: Vec<ExContent>,
    pub colspan: Option<u32>,
    pub rowspan: Option<u32>,
    pub align: Option<String>,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Columns"]
pub struct ExColumns {
    pub count: u32,
    pub body: Vec<ExContent>,
    pub gutter: Option<ExValue>,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Pagebreak"]
pub struct ExPagebreak {
    pub weak: bool,
}

#[derive(Clone, Debug)]
pub struct ExParbreak;

#[derive(Clone, Debug)]
pub struct ExLinebreak;

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Math"]
pub struct ExMath {
    pub content: String,
    pub block: bool,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Bibliography"]
pub struct ExBibliography {
    pub source: String,
    pub style: Option<String>,
    pub full: Option<bool>,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Link"]
pub struct ExLink {
    pub url: String,
    pub body: Vec<ExContent>,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Raw"]
pub struct ExRaw {
    pub text: String,
    pub lang: Option<String>,
    pub block: bool,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Quote"]
pub struct ExQuote {
    pub body: Vec<ExContent>,
    pub block: bool,
    pub attribution: Option<Vec<ExContent>>,
}

#[derive(Clone, Debug, NifUnitEnum)]
pub enum ExListType {
    Bullet,
    Ordered,
}

#[derive(Clone, Debug, NifUnitEnum)]
pub enum ExListDelim {
    Period,
    Paren,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.List"]
pub struct ExList {
    pub children: Vec<ExContent>,
    pub list_type: ExListType,
    pub tight: bool,
    pub start: u32,
    pub delimiter: ExListDelim,
    pub bullet_char: String,
    pub marker_offset: u32,
    pub padding: u32,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.ListItem"]
pub struct ExListItem {
    pub body: Vec<ExContent>,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Enum"]
pub struct ExEnum {
    pub children: Vec<ExContent>,
    pub tight: bool,
    pub start: Option<u32>,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.EnumItem"]
pub struct ExEnumItem {
    pub body: Vec<ExContent>,
    pub number: Option<u32>,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Label"]
pub struct ExLabel {
    pub name: String,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Ref"]
pub struct ExRef {
    pub target: String,
    pub supplement: Option<Vec<ExContent>>,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Align"]
pub struct ExAlign {
    pub alignment: String,
    pub body: Vec<ExContent>,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Block"]
pub struct ExBlock {
    pub body: Vec<ExContent>,
    pub width: Option<ExValue>,
    pub height: Option<ExValue>,
    pub above: Option<ExValue>,
    pub below: Option<ExValue>,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Pad"]
pub struct ExPad {
    pub body: Vec<ExContent>,
    pub left: Option<ExValue>,
    pub right: Option<ExValue>,
    pub top: Option<ExValue>,
    pub bottom: Option<ExValue>,
    pub x: Option<ExValue>,
    pub y: Option<ExValue>,
    pub rest: Option<ExValue>,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Grid"]
pub struct ExGrid {
    pub columns: Vec<ExValue>,
    pub rows: Vec<ExValue>,
    pub children: Vec<ExContent>,
    pub gutter: Option<ExValue>,
    pub stroke: Option<ExValue>,
    pub align: Option<String>,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Strike"]
pub struct ExStrike {
    pub body: Vec<ExContent>,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Sequence"]
pub struct ExSequence {
    pub children: Vec<ExContent>,
}

/// The top-level content enum. Every variant corresponds to a Typst element.
#[derive(Clone, Debug, NifUntaggedEnum)]
pub enum ExContent {
    Text(ExText),
    Space(ExSpace),
    Heading(ExHeading),
    Paragraph(ExParagraph),
    Strong(ExStrong),
    Emph(ExEmph),
    Image(ExImage),
    Figure(ExFigure),
    Table(ExTable),
    TableHeader(ExTableHeader),
    TableRow(ExTableRow),
    TableCell(ExTableCell),
    Columns(ExColumns),
    Pagebreak(ExPagebreak),
    Parbreak(ExParbreak),
    Linebreak(ExLinebreak),
    Math(ExMath),
    Bibliography(ExBibliography),
    Link(ExLink),
    Raw(ExRaw),
    Quote(ExQuote),
    List(ExList),
    ListItem(ExListItem),
    Enum(ExEnum),
    EnumItem(ExEnumItem),
    Label(ExLabel),
    Ref(ExRef),
    Align(ExAlign),
    Block(ExBlock),
    Pad(ExPad),
    Grid(ExGrid),
    Strike(ExStrike),
    Sequence(ExSequence),
}

// --- Values ---

#[derive(Clone, Debug, NifEnum)]
pub enum ExValue {
    Pt(f64),
    Cm(f64),
    Mm(f64),
    Em(f64),
    Fr(f64),
    Pct(f64),
    Deg(f64),
    Auto,
    None,
    Bool(bool),
    Int(i64),
    Float(f64),
    Str(String),
    Array(Vec<ExValue>),
    Dict(Vec<(String, ExValue)>),
}

// --- Style Rules ---

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Styles.SetRule"]
pub struct ExSetRule {
    pub element: String,
    pub fields: Vec<(String, ExValue)>,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Styles.ShowSetRule"]
pub struct ExShowSetRule {
    pub selector: ExSelector,
    pub element: String,
    pub fields: Vec<(String, ExValue)>,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Styles.ShowRule"]
pub struct ExShowRule {
    pub selector: ExSelector,
    pub transform: ExTransform,
}

#[derive(Clone, Debug, NifEnum)]
pub enum ExSelector {
    Element(String),
    ElementWithFields(String, Vec<(String, ExValue)>),
    All,
}

#[derive(Clone, Debug, NifEnum)]
pub enum ExTransform {
    Named(String),
}

#[derive(Clone, Debug, NifEnum)]
pub enum ExStyleRule {
    SetRule(ExSetRule),
    ShowSetRule(ExShowSetRule),
    ShowRule(ExShowRule),
}

// --- Document ---

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Document"]
pub struct ExDocument {
    pub content: Vec<ExContent>,
    pub styles: Vec<ExStyleRule>,
}
