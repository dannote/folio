use std::num::NonZeroUsize;
use std::str::FromStr;

use ecow::{eco_format, EcoString};
use typst::engine::Engine;
use typst::foundations::{Content, NativeElement, Smart};
use typst::layout::{
    Abs, AlignElem, Alignment, Axes, BlockBody, BlockElem, ColbreakElem,
    ColumnsElem, Dir, HElem, HideElem, Length, PadElem,
    PagebreakElem, PlaceElem, Ratio, Rel, RepeatElem, Sizing,
    StackChild, StackElem, TrackSizings, VElem,
};
use typst::text::SpaceElem as TextSpace;
use typst::model::{
    Attribution, DividerElem, EmphElem, EnumItem, FigureCaption, FigureElem,
    FootnoteBody, FootnoteElem, HeadingElem, LinkElem, LinkTarget, ListItem,
    OutlineElem, ParbreakElem, QuoteElem, StrongElem,
    TableChild, TableElem, TableHeader, TableItem, TableCell, TermItem, TermsElem, TitleElem,
};
use typst::text::{
    HighlightElem, LinebreakElem, RawContent, RawElem, SmallcapsElem,
    StrikeElem, SubElem, SuperElem, TextElem, UnderlineElem,
};
use typst::utils::PicoStr;
use typst::visualize::{CircleElem, EllipseElem, ImageElem, LineElem, Paint, PolygonElem, RectElem, SquareElem};

use crate::types::ExContent;
use crate::world::FolioWorld;

// ── Value parsing ────────────────────────────────────────────────────────────

fn parse_abs(s: &str) -> Option<Abs> {
    let s = s.trim();
    if let Some(r) = s.strip_suffix("pt") { r.trim().parse::<f64>().ok().map(Abs::pt) }
    else if let Some(r) = s.strip_suffix("cm") { r.trim().parse::<f64>().ok().map(Abs::cm) }
    else if let Some(r) = s.strip_suffix("mm") { r.trim().parse::<f64>().ok().map(Abs::mm) }
    else if let Some(r) = s.strip_suffix("in") { r.trim().parse::<f64>().ok().map(Abs::inches) }
    else { s.parse::<f64>().ok().map(Abs::pt) }
}

fn parse_rel(s: &str) -> Option<Rel<Length>> {
    let s = s.trim();
    if s.ends_with('%') {
        let pct: f64 = s.trim_end_matches('%').trim().parse().ok()?;
        Some(Ratio::new(pct / 100.0).into())
    } else {
        parse_abs(s).map(Into::into)
    }
}

fn parse_sizing(s: &str) -> Sizing {
    if s == "auto" { Sizing::Auto } else { Sizing::Rel(parse_rel(s).unwrap_or(Rel::one())) }
}

fn smart_rel(opt: Option<&str>) -> Smart<Rel<Length>> {
    match opt {
        None => Smart::Auto,
        Some(v) if v == "auto" => Smart::Auto,
        Some(v) => Smart::Custom(parse_rel(v).unwrap_or(Rel::one())),
    }
}

fn smart_sizing(opt: Option<&str>) -> Sizing {
    match opt {
        None => Sizing::Auto,
        Some(v) if v == "auto" => Sizing::Auto,
        Some(v) => parse_sizing(v),
    }
}

pub fn parse_color(s: &str) -> Option<typst::visualize::Color> {
    let s = s.trim();
    if let Some(hex) = s.strip_prefix('#') {
        match hex.len() {
            6 => Some(typst::visualize::Color::from_u8(
                u8::from_str_radix(&hex[0..2], 16).ok()?,
                u8::from_str_radix(&hex[2..4], 16).ok()?,
                u8::from_str_radix(&hex[4..6], 16).ok()?, 0xFF)),
            3 => Some(typst::visualize::Color::from_u8(
                u8::from_str_radix(&hex[0..1].repeat(2), 16).ok()?,
                u8::from_str_radix(&hex[1..2].repeat(2), 16).ok()?,
                u8::from_str_radix(&hex[2..3].repeat(2), 16).ok()?, 0xFF)),
            _ => None,
        }
    } else if s.starts_with("rgb(") && s.ends_with(')') {
        let inner = &s[4..s.len()-1];
        let p: Vec<&str> = inner.split(',').map(|x| x.trim()).collect();
        if p.len() >= 3 {
            Some(typst::visualize::Color::from_u8(
                p[0].parse().ok()?, p[1].parse().ok()?, p[2].parse().ok()?, 0xFF))
        } else { None }
    } else { named_color(s) }
}

fn named_color(s: &str) -> Option<typst::visualize::Color> {
    use typst::visualize::Color;
    Some(match s {
        "black" => Color::from_u8(0,0,0,0xFF), "white" => Color::from_u8(0xFF,0xFF,0xFF,0xFF),
        "red" => Color::from_u8(0xFF,0,0,0xFF), "green" => Color::from_u8(0,0x80,0,0xFF),
        "blue" => Color::from_u8(0,0,0xFF,0xFF), "yellow" => Color::from_u8(0xFF,0xFF,0,0xFF),
        "gray" | "grey" => Color::from_u8(0x80,0x80,0x80,0xFF),
        "silver" => Color::from_u8(0xC0,0xC0,0xC0,0xFF),
        "aqua" | "cyan" => Color::from_u8(0,0xFF,0xFF,0xFF),
        "magenta" | "fuchsia" => Color::from_u8(0xFF,0,0xFF,0xFF),
        "orange" => Color::from_u8(0xFF,0xA5,0,0xFF), "purple" => Color::from_u8(0x80,0,0x80,0xFF),
        "lime" => Color::from_u8(0,0xFF,0,0xFF), "teal" => Color::from_u8(0,0x80,0x80,0xFF),
        "navy" => Color::from_u8(0,0,0x80,0xFF), "maroon" => Color::from_u8(0x80,0,0,0xFF),
        "olive" => Color::from_u8(0x80,0x80,0,0xFF),
        _ => return None,
    })
}

fn parse_paint(s: &str) -> Option<Paint> { parse_color(s).map(Paint::Solid) }
fn opt_paint(opt: Option<&str>) -> Option<Paint> { opt.and_then(parse_paint) }

fn parse_dir(s: &str) -> Dir {
    match s { "ltr" => Dir::LTR, "rtl" => Dir::RTL, "btt" => Dir::BTT, _ => Dir::TTB }
}

fn parse_align(s: &str) -> Alignment {
    match s { "left" | "start" => Alignment::START, "center" => Alignment::CENTER,
        "right" | "end" => Alignment::END, "top" => Alignment::TOP,
        "bottom" => Alignment::BOTTOM, _ => Alignment::START }
}

fn parse_axes(s: &str) -> Option<Axes<Rel<Length>>> {
    let p: Vec<&str> = s.split(',').collect();
    if p.len() == 2 { Some(Axes::new(parse_rel(p[0])?, parse_rel(p[1])?)) } else { None }
}

// ── Content tree building ────────────────────────────────────────────────────

pub fn build_content(engine: &mut Engine, nodes: &[ExContent]) -> Content {
    let mut seq: Vec<Content> = Vec::new();
    for (i, node) in nodes.iter().enumerate() {
        if i > 0 && is_block(node) && is_block(&nodes[i-1]) {
            seq.push(ParbreakElem::shared().clone());
        }
        seq.push(convert_node(engine, node));
    }
    Content::sequence(seq)
}

fn is_block(node: &ExContent) -> bool {
    match node {
        ExContent::Heading(_) | ExContent::Paragraph(_) | ExContent::List(_)
        | ExContent::Enum(_) | ExContent::Figure(_) | ExContent::Table(_)
        | ExContent::Quote(_) | ExContent::Block(_) | ExContent::Columns(_)
        | ExContent::Pagebreak(_) | ExContent::Colbreak(_) | ExContent::Outline(_)
        | ExContent::Title(_) | ExContent::TermList(_) | ExContent::Divider(_)
        | ExContent::Rect(_) | ExContent::Square(_) | ExContent::Circle(_)
        | ExContent::Ellipse(_) | ExContent::Polygon(_) | ExContent::Stack(_)
        | ExContent::VSpace(_) | ExContent::Footnote(_) => true,
        ExContent::Raw(r) => r.block,
        ExContent::Math(m) => m.block,
        _ => false,
    }
}

fn cc(engine: &mut Engine, nodes: &[ExContent]) -> Content {
    Content::sequence(nodes.iter().map(|n| convert_node(engine, n)).collect::<Vec<_>>())
}

fn convert_node(engine: &mut Engine, node: &ExContent) -> Content {
    match node {
        // Text basics
        ExContent::Text(t) => TextElem::packed(&t.text),
        ExContent::Space(_) => TextSpace::shared().clone(),
        ExContent::Heading(h) => HeadingElem::new(cc(engine, &h.body))
            .with_depth(NonZeroUsize::new(h.level as usize).unwrap_or(NonZeroUsize::MIN)).pack(),
        ExContent::Paragraph(p) => cc(engine, &p.body),

        // Inline formatting
        ExContent::Strong(s) => StrongElem::new(cc(engine, &s.body)).pack(),
        ExContent::Emph(e) => EmphElem::new(cc(engine, &e.body)).pack(),
        ExContent::Strike(s) => StrikeElem::new(cc(engine, &s.body)).pack(),
        ExContent::Underline(u) => UnderlineElem::new(cc(engine, &u.body)).pack(),
        ExContent::Highlight(h) => {
            let mut e = HighlightElem::new(cc(engine, &h.body));
            if let Some(f) = &h.fill { if let Some(p) = parse_paint(f) { e = e.with_fill(Some(p)); } }
            e.pack()
        }
        ExContent::Super(s) => SuperElem::new(cc(engine, &s.body)).pack(),
        ExContent::Sub(s) => SubElem::new(cc(engine, &s.body)).pack(),
        ExContent::Smallcaps(s) => SmallcapsElem::new(cc(engine, &s.body)).pack(),

        // Images & figures
        ExContent::Image(img) => {
            let mut elem = match FolioWorld::get_image_source(&img.src) {
                Some(source) => ImageElem::new(source),
                None => return TextElem::packed(eco_format!("[image: {}]", img.src)),
            };
            elem = elem
                .with_width(smart_rel(img.width.as_deref()))
                .with_height(smart_sizing(img.height.as_deref()));
            if let Some(fit) = &img.fit {
                elem = elem.with_fit(match fit.as_str() {
                    "contain" => typst::visualize::ImageFit::Contain,
                    "stretch" => typst::visualize::ImageFit::Stretch,
                    _ => typst::visualize::ImageFit::Cover,
                });
            }
            elem.pack()
        }
        ExContent::Figure(fig) => {
            let mut e = FigureElem::new(cc(engine, &fig.body));
            if let Some(cap) = &fig.caption {
                e = e.with_caption(Some(typst::foundations::Packed::new(FigureCaption::new(cc(engine, cap)))));
            }
            if let Some(pl) = &fig.placement {
                let va = match pl.as_str() {
                    "bottom" => typst::layout::VAlignment::Bottom,
                    "horizon" | "center" => typst::layout::VAlignment::Horizon,
                    _ => typst::layout::VAlignment::Top,
                };
                e = e.with_placement(Some(Smart::Custom(va)));
            }
            if let Some(scope) = &fig.scope {
                e = e.with_scope(match scope.as_str() {
                    "parent" => typst::layout::PlacementScope::Parent,
                    _ => typst::layout::PlacementScope::Column,
                });
            }
            if let Some(num) = &fig.numbering {
                if let Ok(pat) = typst::model::NumberingPattern::from_str(num) {
                    e = e.with_numbering(Some(typst::model::Numbering::Pattern(pat)));
                }
            }
            e.pack()
        }

        // Tables
        ExContent::Table(tbl) => convert_table(engine, tbl),
        ExContent::TableHeader(_) | ExContent::TableRow(_) => Content::empty(),
        ExContent::TableCell(tc) => cc(engine, &tc.body),

        // Layout
        ExContent::Columns(cols) => {
            let n = NonZeroUsize::new(cols.count as usize).unwrap_or(NonZeroUsize::MIN);
            ColumnsElem::new(cc(engine, &cols.body)).with_count(n).pack()
        }
        ExContent::Colbreak(cb) => ColbreakElem::new().with_weak(cb.weak).pack(),
        ExContent::Pagebreak(pb) => PagebreakElem::new().with_weak(pb.weak).pack(),
        ExContent::Parbreak(_) => ParbreakElem::shared().clone(),
        ExContent::Linebreak(_) => LinebreakElem::shared().clone(),

        ExContent::Align(a) => AlignElem::new(cc(engine, &a.body))
            .with_alignment(parse_align(&a.alignment)).pack(),

        ExContent::Block(b) => BlockElem::new()
            .with_body(Some(BlockBody::Content(cc(engine, &b.body))))
            .with_width(smart_rel(b.width.as_deref()))
            .with_height(smart_sizing(b.height.as_deref())).pack(),

        ExContent::Hide(h) => HideElem::new(cc(engine, &h.body)).pack(),
        ExContent::Repeat(r) => RepeatElem::new(cc(engine, &r.body)).pack(),

        ExContent::Place(p) => {
            let al = p.alignment.as_deref().map(parse_align)
                .map(Smart::Custom).unwrap_or(Smart::Auto);
            PlaceElem::new(cc(engine, &p.body)).with_alignment(al)
                .with_float(p.float.unwrap_or(false)).pack()
        }

        ExContent::VSpace(v) => {
            let amt = parse_rel(&v.amount)
                .map(typst::layout::Spacing::Rel)
                .unwrap_or(typst::layout::Spacing::Rel(Rel::zero()));
            VElem::new(amt).with_weak(v.weak).pack()
        }
        ExContent::HSpace(h) => {
            let amt = parse_rel(&h.amount)
                .map(typst::layout::Spacing::Rel)
                .unwrap_or(typst::layout::Spacing::Rel(Rel::zero()));
            HElem::new(amt).with_weak(h.weak).pack()
        }

        ExContent::Pad(p) => {
            let z = Rel::zero();
            PadElem::new(cc(engine, &p.body))
                .with_left(p.left.as_deref().and_then(parse_rel).unwrap_or(z))
                .with_top(p.top.as_deref().and_then(parse_rel).unwrap_or(z))
                .with_right(p.right.as_deref().and_then(parse_rel).unwrap_or(z))
                .with_bottom(p.bottom.as_deref().and_then(parse_rel).unwrap_or(z)).pack()
        }

        ExContent::Stack(st) => {
            let ch: Vec<StackChild> = st.children.iter()
                .map(|c| StackChild::Block(convert_node(engine, c))).collect();
            StackElem::new(ch).with_dir(parse_dir(&st.dir)).pack()
        }

        // Shapes
        ExContent::Rect(r) => RectElem::new()
            .with_body(Some(cc(engine, &r.body)))
            .with_width(smart_rel(r.width.as_deref()))
            .with_height(smart_sizing(r.height.as_deref()))
            .with_fill(opt_paint(r.fill.as_deref())).pack(),

        ExContent::Square(sq) => SquareElem::new()
            .with_body(Some(cc(engine, &sq.body)))
            .with_width(smart_rel(sq.size.as_deref()))
            .with_fill(opt_paint(sq.fill.as_deref())).pack(),

        ExContent::Circle(c) => CircleElem::new()
            .with_body(Some(cc(engine, &c.body)))
            .with_width(c.radius.as_deref().map(|r| {
                // Typst internally doubles radius → width, we must too
                parse_rel(r)
                    .map(|rel| Smart::Custom(rel * 2.0))
                    .unwrap_or(Smart::Auto)
            }).unwrap_or(Smart::Auto))
            .with_fill(opt_paint(c.fill.as_deref())).pack(),

        ExContent::Ellipse(e) => EllipseElem::new()
            .with_body(Some(cc(engine, &e.body)))
            .with_width(smart_rel(e.width.as_deref()))
            .with_height(smart_sizing(e.height.as_deref()))
            .with_fill(opt_paint(e.fill.as_deref())).pack(),

        ExContent::Line(l) => {
            let start = l.start.as_deref().and_then(parse_axes).unwrap_or(Axes::splat(Rel::zero()));
            let mut el = LineElem::new().with_start(start);
            if let Some(end) = &l.end { if let Some(e) = parse_axes(end) { el = el.with_end(Some(e)); } }
            el.pack()
        }

        ExContent::Polygon(pg) => {
            let verts: Vec<Axes<Rel<Length>>> = pg.vertices.iter().filter_map(|v| parse_axes(v)).collect();
            PolygonElem::new(verts).with_fill(opt_paint(pg.fill.as_deref())).pack()
        }

        // Document structure
        ExContent::Outline(o) => {
            let mut e = OutlineElem::new();
            if let Some(title) = &o.title {
                e = e.with_title(Smart::Custom(Some(TextElem::packed(title.clone()))));
            }
            if let Some(d) = o.depth {
                e = e.with_depth(Some(NonZeroUsize::new(d as _).unwrap_or(NonZeroUsize::MIN)));
            }
            e.pack()
        }

        ExContent::Title(t) => TitleElem::new().with_body(Smart::Custom(cc(engine, &t.body))).pack(),
        ExContent::Divider(_) => DividerElem::new().pack(),

        ExContent::TermList(tl) => {
            let items: Vec<typst::foundations::Packed<TermItem>> = tl.children.iter().filter_map(|c| match c {
                ExContent::TermItem(ti) => Some(typst::foundations::Packed::new(TermItem::new(cc(engine, &ti.term), cc(engine, &ti.description)))),
                _ => None,
            }).collect();
            TermsElem::new(items).with_tight(tl.tight).pack()
        }
        ExContent::TermItem(_) => Content::empty(),

        ExContent::Footnote(fn_) => FootnoteElem::new(FootnoteBody::Content(cc(engine, &fn_.body))).pack(),

        // Math, Links, Code
        ExContent::Math(m) => FolioWorld::eval_math(engine, &m.content, m.block),

        ExContent::Link(link) => {
            let dest = typst::model::Destination::Url(
                typst::model::Url::new(&link.url).unwrap_or_else(|_| typst::model::Url::new("about:blank").unwrap()));
            let body = if link.body.is_empty() { TextElem::packed(&link.url) } else { cc(engine, &link.body) };
            LinkElem::new(LinkTarget::Dest(dest), body).pack()
        }

        ExContent::Raw(raw) => {
            let content = RawContent::Text(EcoString::from(&raw.text));
            let mut e = RawElem::new(content).with_block(raw.block);
            if let Some(lang) = &raw.lang { e = e.with_lang(Some(EcoString::from(lang))); }
            e.pack()
        }

        // Quotes, Lists
        ExContent::Quote(q) => {
            let mut e = QuoteElem::new(cc(engine, &q.body)).with_block(q.block);
            if let Some(attr) = &q.attribution {
                e = e.with_attribution(Some(Attribution::Content(cc(engine, attr))));
            }
            e.pack()
        }

        ExContent::List(list) => Content::sequence(list.children.iter().map(|c| convert_node(engine, c)).collect::<Vec<_>>()),
        ExContent::ListItem(li) => ListItem::new(cc(engine, &li.body)).pack(),

        ExContent::Enum(en) => Content::sequence(en.children.iter().map(|c| convert_node(engine, c)).collect::<Vec<_>>()),
        ExContent::EnumItem(ei) => {
            let mut e = EnumItem::new(cc(engine, &ei.body));
            if let Some(n) = ei.number { e.number.set(Smart::Custom(n as u64)); }
            e.pack()
        }

        // Labels & Refs
        ExContent::Label(label) => {
            if let Some(lbl) = typst::foundations::Label::new(PicoStr::intern(&label.name)) {
                Content::empty().labelled(lbl)
            } else { Content::empty() }
        }
        ExContent::Ref(r) => {
            if let Some(lbl) = typst::foundations::Label::new(PicoStr::intern(&r.target)) {
                typst::model::RefElem::new(lbl).pack()
            } else { TextElem::packed(&r.target) }
        }

        ExContent::Sequence(seq) => cc(engine, &seq.children),
    }
}

// ── Table conversion ─────────────────────────────────────────────────────────

fn convert_table(engine: &mut Engine, tbl: &crate::types::ExTable) -> Content {
    let ncols = count_columns(tbl);
    let cols = TrackSizings(std::iter::repeat_with(|| Sizing::Auto).take(ncols).collect());
    let mut children: Vec<TableChild> = Vec::new();

    let mut make_cell = |tc: &crate::types::ExTableCell| {
        let mut cell = TableCell::new(cc(engine, &tc.body));
        if let Some(rs) = tc.rowspan { cell = cell.with_rowspan(NonZeroUsize::new(rs as _).unwrap_or(NonZeroUsize::MIN)); }
        if let Some(cs) = tc.colspan { cell = cell.with_colspan(NonZeroUsize::new(cs as _).unwrap_or(NonZeroUsize::MIN)); }
        if let Some(al) = &tc.align { cell = cell.with_align(Smart::Custom(parse_align(al))); }
        TableItem::Cell(typst::foundations::Packed::new(cell))
    };

    for child in &tbl.children {
        match child {
            ExContent::TableHeader(th) => {
                let cells: Vec<TableItem> = th.children.iter().filter_map(|c| match c {
                    ExContent::TableCell(tc) => Some(make_cell(tc)),
                    _ => None,
                }).collect();
                children.push(TableChild::Header(typst::foundations::Packed::new(TableHeader::new(cells))));
            }
            ExContent::TableRow(tr) => {
                for cn in &tr.children {
                    if let ExContent::TableCell(tc) = cn {
                        children.push(TableChild::Item(make_cell(tc)));
                    }
                }
            }
            ExContent::TableCell(tc) => {
                children.push(TableChild::Item(make_cell(tc)));
            }
            _ => {}
        }
    }

    let mut elem = TableElem::new(children).with_columns(cols);
    if let Some(g) = &tbl.gutter {
        if let Some(r) = parse_rel(g) {
            elem = elem.with_row_gutter(TrackSizings(smallvec::smallvec![Sizing::Rel(r)]));
            elem = elem.with_column_gutter(TrackSizings(smallvec::smallvec![Sizing::Rel(r)]));
        }
    }
    elem.pack()
}

fn count_columns(tbl: &crate::types::ExTable) -> usize {
    let mut max_cols: usize = 0;
    for child in &tbl.children {
        match child {
            ExContent::TableHeader(th) => max_cols = max_cols.max(th.children.len()),
            ExContent::TableRow(tr) => max_cols = max_cols.max(tr.children.len()),
            ExContent::TableCell(_) => max_cols = max_cols.max(1),
            _ => {}
        }
    }
    max_cols.max(1)
}
