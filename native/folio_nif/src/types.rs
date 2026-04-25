use rustler::{NifStruct, NifUntaggedEnum};

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
#[module = "Folio.Content.Cite"]
pub struct ExCite {
    pub key: String,
    pub supplement: Option<Vec<ExContent>>,
    pub form: Option<String>,
    pub style: Option<String>,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Bibliography"]
pub struct ExBibliography {
    pub sources: Vec<String>,
    pub title: Option<Vec<ExContent>>,
    pub full: bool,
    pub style: Option<String>,
}

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
    pub columns: Option<Vec<String>>,
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
#[module = "Folio.Content.EnumList"]
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
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Square"]
pub struct ExSquare {
    pub body: Vec<ExContent>,
    pub size: Option<String>,
    pub fill: Option<String>,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Circle"]
pub struct ExCircle {
    pub body: Vec<ExContent>,
    pub radius: Option<String>,
    pub fill: Option<String>,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Ellipse"]
pub struct ExEllipse {
    pub body: Vec<ExContent>,
    pub width: Option<String>,
    pub height: Option<String>,
    pub fill: Option<String>,
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
#[module = "Folio.Content.Grid"]
pub struct ExGrid {
    pub columns: Option<Vec<String>>,
    pub rows: Option<Vec<String>>,
    pub gutter: Option<String>,
    pub children: Vec<ExContent>,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.GridCell"]
pub struct ExGridCell {
    pub body: Vec<ExContent>,
    pub colspan: Option<u32>,
    pub rowspan: Option<u32>,
    pub align: Option<String>,
    pub fill: Option<String>,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.LocalSet"]
pub struct ExLocalSet {
    pub body: Vec<ExContent>,
    pub hyphenate: Option<bool>,
    pub justify: Option<bool>,
    pub first_line_indent: Option<f64>,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.RawTypst"]
pub struct ExRawTypst {
    pub source: String,
}

#[derive(Clone, Debug, NifStruct)]
#[module = "Folio.Content.Sequence"]
pub struct ExSequence { pub children: Vec<ExContent> }

// O(1) decoder: read __struct__ atom, dispatch directly instead of
// trying 56 variants sequentially like NifUntaggedEnum does.
#[derive(Clone, Debug)]
pub enum ExContent {
    Text(ExText),
    Space(ExSpace),
    Heading(ExHeading),
    Cite(ExCite),
    Bibliography(ExBibliography),
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
    Grid(ExGrid),
    GridCell(ExGridCell),
    LocalSet(ExLocalSet),
    RawTypst(ExRawTypst),
    Sequence(ExSequence),
}

rustler::atoms! {
    atom_struct = "__struct__",
}

impl<'a> rustler::Decoder<'a> for ExContent {
    fn decode(term: rustler::Term<'a>) -> rustler::NifResult<Self> {
        use rustler::Decoder;
        let env = term.get_env();
        let module: rustler::Atom = term.map_get(atom_struct())?.decode()?;
        let name_str = module.to_term(env).atom_to_string()?;
        match name_str.as_str() {
            "Elixir.Folio.Content.Text" => Ok(ExContent::Text(Decoder::decode(term)?)),
            "Elixir.Folio.Content.Space" => Ok(ExContent::Space(Decoder::decode(term)?)),
            "Elixir.Folio.Content.Heading" => Ok(ExContent::Heading(Decoder::decode(term)?)),
            "Elixir.Folio.Content.Cite" => Ok(ExContent::Cite(Decoder::decode(term)?)),
            "Elixir.Folio.Content.Bibliography" => Ok(ExContent::Bibliography(Decoder::decode(term)?)),
            "Elixir.Folio.Content.Paragraph" => Ok(ExContent::Paragraph(Decoder::decode(term)?)),
            "Elixir.Folio.Content.Strong" => Ok(ExContent::Strong(Decoder::decode(term)?)),
            "Elixir.Folio.Content.Emph" => Ok(ExContent::Emph(Decoder::decode(term)?)),
            "Elixir.Folio.Content.Strike" => Ok(ExContent::Strike(Decoder::decode(term)?)),
            "Elixir.Folio.Content.Underline" => Ok(ExContent::Underline(Decoder::decode(term)?)),
            "Elixir.Folio.Content.Highlight" => Ok(ExContent::Highlight(Decoder::decode(term)?)),
            "Elixir.Folio.Content.Super" => Ok(ExContent::Super(Decoder::decode(term)?)),
            "Elixir.Folio.Content.Sub" => Ok(ExContent::Sub(Decoder::decode(term)?)),
            "Elixir.Folio.Content.Smallcaps" => Ok(ExContent::Smallcaps(Decoder::decode(term)?)),
            "Elixir.Folio.Content.Image" => Ok(ExContent::Image(Decoder::decode(term)?)),
            "Elixir.Folio.Content.Figure" => Ok(ExContent::Figure(Decoder::decode(term)?)),
            "Elixir.Folio.Content.Table" => Ok(ExContent::Table(Decoder::decode(term)?)),
            "Elixir.Folio.Content.TableHeader" => Ok(ExContent::TableHeader(Decoder::decode(term)?)),
            "Elixir.Folio.Content.TableRow" => Ok(ExContent::TableRow(Decoder::decode(term)?)),
            "Elixir.Folio.Content.TableCell" => Ok(ExContent::TableCell(Decoder::decode(term)?)),
            "Elixir.Folio.Content.Columns" => Ok(ExContent::Columns(Decoder::decode(term)?)),
            "Elixir.Folio.Content.Colbreak" => Ok(ExContent::Colbreak(Decoder::decode(term)?)),
            "Elixir.Folio.Content.Pagebreak" => Ok(ExContent::Pagebreak(Decoder::decode(term)?)),
            "Elixir.Folio.Content.Parbreak" => Ok(ExContent::Parbreak(Decoder::decode(term)?)),
            "Elixir.Folio.Content.Linebreak" => Ok(ExContent::Linebreak(Decoder::decode(term)?)),
            "Elixir.Folio.Content.Math" => Ok(ExContent::Math(Decoder::decode(term)?)),
            "Elixir.Folio.Content.Link" => Ok(ExContent::Link(Decoder::decode(term)?)),
            "Elixir.Folio.Content.Raw" => Ok(ExContent::Raw(Decoder::decode(term)?)),
            "Elixir.Folio.Content.Quote" => Ok(ExContent::Quote(Decoder::decode(term)?)),
            "Elixir.Folio.Content.List" => Ok(ExContent::List(Decoder::decode(term)?)),
            "Elixir.Folio.Content.ListItem" => Ok(ExContent::ListItem(Decoder::decode(term)?)),
            "Elixir.Folio.Content.EnumList" => Ok(ExContent::Enum(Decoder::decode(term)?)),
            "Elixir.Folio.Content.EnumItem" => Ok(ExContent::EnumItem(Decoder::decode(term)?)),
            "Elixir.Folio.Content.Label" => Ok(ExContent::Label(Decoder::decode(term)?)),
            "Elixir.Folio.Content.Ref" => Ok(ExContent::Ref(Decoder::decode(term)?)),
            "Elixir.Folio.Content.Align" => Ok(ExContent::Align(Decoder::decode(term)?)),
            "Elixir.Folio.Content.Block" => Ok(ExContent::Block(Decoder::decode(term)?)),
            "Elixir.Folio.Content.Hide" => Ok(ExContent::Hide(Decoder::decode(term)?)),
            "Elixir.Folio.Content.Repeat" => Ok(ExContent::Repeat(Decoder::decode(term)?)),
            "Elixir.Folio.Content.Place" => Ok(ExContent::Place(Decoder::decode(term)?)),
            "Elixir.Folio.Content.VSpace" => Ok(ExContent::VSpace(Decoder::decode(term)?)),
            "Elixir.Folio.Content.HSpace" => Ok(ExContent::HSpace(Decoder::decode(term)?)),
            "Elixir.Folio.Content.Pad" => Ok(ExContent::Pad(Decoder::decode(term)?)),
            "Elixir.Folio.Content.Stack" => Ok(ExContent::Stack(Decoder::decode(term)?)),
            "Elixir.Folio.Content.Rect" => Ok(ExContent::Rect(Decoder::decode(term)?)),
            "Elixir.Folio.Content.Square" => Ok(ExContent::Square(Decoder::decode(term)?)),
            "Elixir.Folio.Content.Circle" => Ok(ExContent::Circle(Decoder::decode(term)?)),
            "Elixir.Folio.Content.Ellipse" => Ok(ExContent::Ellipse(Decoder::decode(term)?)),
            "Elixir.Folio.Content.Line" => Ok(ExContent::Line(Decoder::decode(term)?)),
            "Elixir.Folio.Content.Polygon" => Ok(ExContent::Polygon(Decoder::decode(term)?)),
            "Elixir.Folio.Content.Outline" => Ok(ExContent::Outline(Decoder::decode(term)?)),
            "Elixir.Folio.Content.Title" => Ok(ExContent::Title(Decoder::decode(term)?)),
            "Elixir.Folio.Content.TermList" => Ok(ExContent::TermList(Decoder::decode(term)?)),
            "Elixir.Folio.Content.TermItem" => Ok(ExContent::TermItem(Decoder::decode(term)?)),
            "Elixir.Folio.Content.Footnote" => Ok(ExContent::Footnote(Decoder::decode(term)?)),
            "Elixir.Folio.Content.Divider" => Ok(ExContent::Divider(Decoder::decode(term)?)),
            "Elixir.Folio.Content.Grid" => Ok(ExContent::Grid(Decoder::decode(term)?)),
            "Elixir.Folio.Content.GridCell" => Ok(ExContent::GridCell(Decoder::decode(term)?)),
            "Elixir.Folio.Content.LocalSet" => Ok(ExContent::LocalSet(Decoder::decode(term)?)),
            "Elixir.Folio.Content.RawTypst" => Ok(ExContent::RawTypst(Decoder::decode(term)?)),
            "Elixir.Folio.Content.Sequence" => Ok(ExContent::Sequence(Decoder::decode(term)?)),
            _ => Err(rustler::Error::RaiseAtom("unknown_content_variant")),
        }
    }
}

impl rustler::Encoder for ExContent {
    fn encode<'a>(&self, env: rustler::Env<'a>) -> rustler::Term<'a> {
        match self {
            ExContent::Text(v) => v.encode(env),
            ExContent::Space(v) => v.encode(env),
            ExContent::Heading(v) => v.encode(env),
            ExContent::Cite(v) => v.encode(env),
            ExContent::Bibliography(v) => v.encode(env),
            ExContent::Paragraph(v) => v.encode(env),
            ExContent::Strong(v) => v.encode(env),
            ExContent::Emph(v) => v.encode(env),
            ExContent::Strike(v) => v.encode(env),
            ExContent::Underline(v) => v.encode(env),
            ExContent::Highlight(v) => v.encode(env),
            ExContent::Super(v) => v.encode(env),
            ExContent::Sub(v) => v.encode(env),
            ExContent::Smallcaps(v) => v.encode(env),
            ExContent::Image(v) => v.encode(env),
            ExContent::Figure(v) => v.encode(env),
            ExContent::Table(v) => v.encode(env),
            ExContent::TableHeader(v) => v.encode(env),
            ExContent::TableRow(v) => v.encode(env),
            ExContent::TableCell(v) => v.encode(env),
            ExContent::Columns(v) => v.encode(env),
            ExContent::Colbreak(v) => v.encode(env),
            ExContent::Pagebreak(v) => v.encode(env),
            ExContent::Parbreak(v) => v.encode(env),
            ExContent::Linebreak(v) => v.encode(env),
            ExContent::Math(v) => v.encode(env),
            ExContent::Link(v) => v.encode(env),
            ExContent::Raw(v) => v.encode(env),
            ExContent::Quote(v) => v.encode(env),
            ExContent::List(v) => v.encode(env),
            ExContent::ListItem(v) => v.encode(env),
            ExContent::Enum(v) => v.encode(env),
            ExContent::EnumItem(v) => v.encode(env),
            ExContent::Label(v) => v.encode(env),
            ExContent::Ref(v) => v.encode(env),
            ExContent::Align(v) => v.encode(env),
            ExContent::Block(v) => v.encode(env),
            ExContent::Hide(v) => v.encode(env),
            ExContent::Repeat(v) => v.encode(env),
            ExContent::Place(v) => v.encode(env),
            ExContent::VSpace(v) => v.encode(env),
            ExContent::HSpace(v) => v.encode(env),
            ExContent::Pad(v) => v.encode(env),
            ExContent::Stack(v) => v.encode(env),
            ExContent::Rect(v) => v.encode(env),
            ExContent::Square(v) => v.encode(env),
            ExContent::Circle(v) => v.encode(env),
            ExContent::Ellipse(v) => v.encode(env),
            ExContent::Line(v) => v.encode(env),
            ExContent::Polygon(v) => v.encode(env),
            ExContent::Outline(v) => v.encode(env),
            ExContent::Title(v) => v.encode(env),
            ExContent::TermList(v) => v.encode(env),
            ExContent::TermItem(v) => v.encode(env),
            ExContent::Footnote(v) => v.encode(env),
            ExContent::Divider(v) => v.encode(env),
            ExContent::Grid(v) => v.encode(env),
            ExContent::GridCell(v) => v.encode(env),
            ExContent::LocalSet(v) => v.encode(env),
            ExContent::RawTypst(v) => v.encode(env),
            ExContent::Sequence(v) => v.encode(env),
        }
    }
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
