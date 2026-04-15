use rustler::NifStruct;
use rustler::NifUntaggedEnum;

// --- Content Nodes ---

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Text"]
pub struct ExText {
    pub text: String,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Space"]
pub struct ExSpace {}

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
#[module = "Folio.Content.Strike"]
pub struct ExStrike {
    pub body: Vec<ExContent>,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Image"]
pub struct ExImage {
    pub src: String,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Figure"]
pub struct ExFigure {
    pub body: Vec<ExContent>,
    pub caption: Option<Vec<ExContent>>,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Table"]
pub struct ExTable {
    pub num_columns: usize,
    pub children: Vec<ExContent>,
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
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Columns"]
pub struct ExColumns {
    pub count: u32,
    pub body: Vec<ExContent>,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Pagebreak"]
pub struct ExPagebreak {}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Parbreak"]
pub struct ExParbreak {}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Linebreak"]
pub struct ExLinebreak {}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Math"]
pub struct ExMath {
    pub content: String,
    pub block: bool,
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
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.List"]
pub struct ExList {
    pub children: Vec<ExContent>,
    pub tight: bool,
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
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Sequence"]
pub struct ExSequence {
    pub children: Vec<ExContent>,
}

#[derive(Clone, Debug, NifUntaggedEnum)]
pub enum ExContent {
    Text(ExText),
    Space(ExSpace),
    Heading(ExHeading),
    Paragraph(ExParagraph),
    Strong(ExStrong),
    Emph(ExEmph),
    Strike(ExStrike),
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
    Sequence(ExSequence),
}

// --- Style Rules ---

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Styles.PagePaper"]
pub struct ExPagePaper {
    pub paper: String,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Styles.PageSize"]
pub struct ExPageSize {
    pub width: Option<f64>,
    pub height: Option<f64>,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Styles.PageMargin"]
pub struct ExPageMargin {
    pub top: Option<f64>,
    pub right: Option<f64>,
    pub bottom: Option<f64>,
    pub left: Option<f64>,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Styles.FontSize"]
pub struct ExFontSize {
    pub size: f64,
}

#[derive(Clone, Debug, NifUntaggedEnum)]
pub enum ExStyle {
    PagePaper(ExPagePaper),
    PageSize(ExPageSize),
    PageMargin(ExPageMargin),
    FontSize(ExFontSize),
}
