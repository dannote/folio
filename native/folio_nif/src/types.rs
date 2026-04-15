use rustler::NifStruct;
use rustler::NifUntaggedEnum;

// --- Content Nodes ---

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Text"]
pub struct ExText { pub text: String }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Space"]
pub struct ExSpace {}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Heading"]
pub struct ExHeading { pub body: Vec<ExContent>, pub level: u8 }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Paragraph"]
pub struct ExParagraph { pub body: Vec<ExContent> }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Strong"]
pub struct ExStrong { pub body: Vec<ExContent> }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Emph"]
pub struct ExEmph { pub body: Vec<ExContent> }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Strike"]
pub struct ExStrike { pub body: Vec<ExContent> }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Underline"]
pub struct ExUnderline { pub body: Vec<ExContent> }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Highlight"]
pub struct ExHighlight { pub body: Vec<ExContent>, pub fill: Option<String> }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Super"]
pub struct ExSuper { pub body: Vec<ExContent> }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Sub"]
pub struct ExSub { pub body: Vec<ExContent> }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Smallcaps"]
pub struct ExSmallcaps { pub body: Vec<ExContent> }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Image"]
pub struct ExImage {
    pub src: String,
    pub width: Option<String>,
    pub height: Option<String>,
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
    pub columns: Option<String>,
    pub rows: Option<String>,
    pub children: Vec<ExContent>,
    pub stroke: Option<String>,
    pub gutter: Option<String>,
    pub align: Option<String>,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.TableHeader"]
pub struct ExTableHeader { pub children: Vec<ExContent> }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.TableRow"]
pub struct ExTableRow { pub children: Vec<ExContent> }

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
pub struct ExColumns { pub count: u32, pub body: Vec<ExContent>, pub gutter: Option<String> }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Colbreak"]
pub struct ExColbreak { pub weak: bool }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Pagebreak"]
pub struct ExPagebreak { pub weak: bool }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Parbreak"]
pub struct ExParbreak {}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Linebreak"]
pub struct ExLinebreak {}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Math"]
pub struct ExMath { pub content: String, pub block: bool }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Link"]
pub struct ExLink { pub url: String, pub body: Vec<ExContent> }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Raw"]
pub struct ExRaw { pub text: String, pub lang: Option<String>, pub block: bool }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Quote"]
pub struct ExQuote {
    pub body: Vec<ExContent>,
    pub block: bool,
    pub attribution: Option<Vec<ExContent>>,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.List"]
pub struct ExList { pub children: Vec<ExContent>, pub tight: bool, pub marker: Option<String> }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.ListItem"]
pub struct ExListItem { pub body: Vec<ExContent> }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Enum"]
pub struct ExEnum { pub children: Vec<ExContent>, pub tight: bool, pub start: Option<u32> }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.EnumItem"]
pub struct ExEnumItem { pub body: Vec<ExContent>, pub number: Option<u32> }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Label"]
pub struct ExLabel { pub name: String }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Ref"]
pub struct ExRef { pub target: String, pub supplement: Option<Vec<ExContent>> }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Align"]
pub struct ExAlign { pub alignment: String, pub body: Vec<ExContent> }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Block"]
pub struct ExBlock {
    pub body: Vec<ExContent>,
    pub width: Option<String>,
    pub height: Option<String>,
    pub above: Option<String>,
    pub below: Option<String>,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Hide"]
pub struct ExHide { pub body: Vec<ExContent> }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Repeat"]
pub struct ExRepeat { pub body: Vec<ExContent> }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Place"]
pub struct ExPlace { pub alignment: Option<String>, pub body: Vec<ExContent>, pub float: Option<bool> }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.VSpace"]
pub struct ExVSpace { pub amount: String, pub weak: bool }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.HSpace"]
pub struct ExHSpace { pub amount: String, pub weak: bool }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Pad"]
pub struct ExPad {
    pub body: Vec<ExContent>,
    pub left: Option<String>,
    pub right: Option<String>,
    pub top: Option<String>,
    pub bottom: Option<String>,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Stack"]
pub struct ExStack { pub dir: String, pub children: Vec<ExContent>, pub spacing: Option<String> }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Rect"]
pub struct ExRect {
    pub body: Vec<ExContent>,
    pub width: Option<String>,
    pub height: Option<String>,
    pub fill: Option<String>,
    pub stroke: Option<String>,
    pub inset: Option<String>,
    pub outset: Option<String>,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Square"]
pub struct ExSquare {
    pub body: Vec<ExContent>,
    pub size: Option<String>,
    pub fill: Option<String>,
    pub stroke: Option<String>,
    pub inset: Option<String>,
    pub outset: Option<String>,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Circle"]
pub struct ExCircle {
    pub body: Vec<ExContent>,
    pub radius: Option<String>,
    pub fill: Option<String>,
    pub stroke: Option<String>,
    pub inset: Option<String>,
    pub outset: Option<String>,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Ellipse"]
pub struct ExEllipse {
    pub body: Vec<ExContent>,
    pub width: Option<String>,
    pub height: Option<String>,
    pub fill: Option<String>,
    pub stroke: Option<String>,
    pub inset: Option<String>,
    pub outset: Option<String>,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Line"]
pub struct ExLine {
    pub start: Option<String>,
    pub end: Option<String>,
    pub length: Option<String>,
    pub angle: Option<String>,
    pub stroke: Option<String>,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Polygon"]
pub struct ExPolygon {
    pub vertices: Vec<String>,
    pub fill: Option<String>,
    pub stroke: Option<String>,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Outline"]
pub struct ExOutline {
    pub title: Option<String>,
    pub indent: Option<String>,
    pub depth: Option<u32>,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Title"]
pub struct ExTitle { pub body: Vec<ExContent> }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.TermList"]
pub struct ExTermList { pub children: Vec<ExContent>, pub tight: bool }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.TermItem"]
pub struct ExTermItem { pub term: Vec<ExContent>, pub description: Vec<ExContent> }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Footnote"]
pub struct ExFootnote { pub body: Vec<ExContent> }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Divider"]
pub struct ExDivider {}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Sequence"]
pub struct ExSequence { pub children: Vec<ExContent> }

#[derive(Clone, Debug, NifUntaggedEnum)]
pub enum ExContent {
    Text(ExText),
    Space(ExSpace),
    Heading(ExHeading),
    Paragraph(ExParagraph),
    Strong(ExStrong),
    Emph(ExEmph),
    Strike(ExStrike),
    Underline(ExUnderline),
    Highlight(ExHighlight),
    Super(ExSuper),
    Sub(ExSub),
    Smallcaps(ExSmallcaps),
    Image(ExImage),
    Figure(ExFigure),
    Table(ExTable),
    TableHeader(ExTableHeader),
    TableRow(ExTableRow),
    TableCell(ExTableCell),
    Columns(ExColumns),
    Colbreak(ExColbreak),
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
    Hide(ExHide),
    Repeat(ExRepeat),
    Place(ExPlace),
    VSpace(ExVSpace),
    HSpace(ExHSpace),
    Pad(ExPad),
    Stack(ExStack),
    Rect(ExRect),
    Square(ExSquare),
    Circle(ExCircle),
    Ellipse(ExEllipse),
    Line(ExLine),
    Polygon(ExPolygon),
    Outline(ExOutline),
    Title(ExTitle),
    TermList(ExTermList),
    TermItem(ExTermItem),
    Footnote(ExFootnote),
    Divider(ExDivider),
    Sequence(ExSequence),
}

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
pub struct ExParIndent { pub indent: f64 }

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Styles.PageNumbering"]
pub struct ExPageNumbering { pub pattern: String }

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
}
