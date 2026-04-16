use std::num::NonZeroUsize;
use std::str::FromStr;

use ecow::{eco_format, EcoString};
use typst::engine::Engine;
use typst::foundations::{Bytes, Content, NativeElement, OneOrMultiple, Smart};
use typst::layout::{
    Abs, AlignElem, Alignment, Axes, BlockBody, BlockElem, ColbreakElem,
    ColumnsElem, Dir, HElem, HideElem, Length, PadElem,
    PagebreakElem, PlaceElem, Ratio, Rel, RepeatElem, Sizing,
    StackChild, StackElem, TrackSizings, VElem,
};
use typst::text::SpaceElem as TextSpace;
use typst::model::{
    Attribution, Bibliography, BibliographyElem, CitationForm, CiteElem, DividerElem,
    EmphElem, EnumElem, EnumItem, FigureCaption, FigureElem, FootnoteBody, FootnoteElem,
    HeadingElem, LinkElem, LinkTarget, ListElem, ListItem, OutlineElem, ParbreakElem,
    QuoteElem, StrongElem, TableCell, TableChild, TableElem, TableHeader,
    TableItem, TermItem, TermsElem, TitleElem,
};
use typst::text::{
    HighlightElem, LinebreakElem, RawContent, RawElem, SmallcapsElem,
    StrikeElem, SubElem, SuperElem, TextElem, UnderlineElem,
};
use typst::utils::PicoStr;
use typst::layout::Angle;
use typst::visualize::{CircleElem, EllipseElem, ImageElem, LineElem, Paint, PolygonElem, RectElem, SquareElem, Stroke};

use crate::types::ExContent;
use crate::world::FolioWorld;
use typst::loading::DataSource;
use typst::syntax::{Span, Spanned};

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
        None | Some("auto") => Smart::Auto,
        Some(v) => Smart::Custom(parse_rel(v).unwrap_or(Rel::one())),
    }
}

fn smart_sizing(opt: Option<&str>) -> Sizing {
    match opt {
        None | Some("auto") => Sizing::Auto,
        Some(v) => parse_sizing(v),
    }
}

pub fn parse_color(s: &str) -> Option<typst::visualize::Color> {
    use std::str::FromStr;
    let s = s.trim();

    // Handle rgb() function syntax (Typst doesn't parse this)
    if s.starts_with("rgb(") && s.ends_with(')') {
        let inner = &s[4..s.len()-1];
        let p: Vec<&str> = inner.split(',').map(|x| x.trim()).collect();
        if p.len() >= 3 {
            Some(typst::visualize::Color::from_u8(
                p[0].parse().ok()?, p[1].parse().ok()?, p[2].parse().ok()?, 0xFF))
        } else { None }
    } else {
        // Delegate everything else (hex, named colors) to Typst
        typst::visualize::Color::from_str(s).ok()
    }
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

fn parse_angle(s: &str) -> Option<Angle> {
    let s = s.trim();
    if let Some(r) = s.strip_suffix("deg") { r.trim().parse::<f64>().ok().map(Angle::deg) }
    else if let Some(r) = s.strip_suffix("rad") { r.trim().parse::<f64>().ok().map(Angle::rad) }
    else { s.parse::<f64>().ok().map(Angle::deg) }
}

fn parse_stroke(s: &str) -> Option<Stroke> {
    let s = s.trim();
    // Try "thickness+color" format (e.g. "2pt + red", "1pt+#ff0000")
    if let Some((lhs, rhs)) = s.split_once('+') {
        let thickness = parse_abs(lhs.trim())?;
        let paint = parse_paint(rhs.trim())?;
        return Some(Stroke::from_pair(paint, thickness.into()));
    }
    // Color-only stroke (default thickness)
    if let Some(paint) = parse_paint(s) {
        return Some(Stroke { paint: Smart::Custom(paint), ..Default::default() });
    }
    // Thickness-only stroke (default color)
    if let Some(thickness) = parse_abs(s) {
        return Some(Stroke { thickness: Smart::Custom(thickness.into()), ..Default::default() });
    }
    None
}

fn parse_axes(s: &str) -> Option<Axes<Rel<Length>>> {
    let p: Vec<&str> = s.split(',').collect();
    if p.len() == 2 { Some(Axes::new(parse_rel(p[0])?, parse_rel(p[1])?)) } else { None }
}

fn bibliography_sources(paths: &[String]) -> Option<OneOrMultiple<DataSource>> {
    let sources = paths
        .iter()
        .map(|path| crate::world::get_file_data(path).map(|bytes| DataSource::Bytes(Bytes::new(bytes))))
        .collect::<Option<Vec<_>>>()?;

    Some(OneOrMultiple(sources))
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
        ExContent::Cite(cite) => {
            let Some(label) = typst::foundations::Label::new(PicoStr::intern(&cite.key)) else {
                return TextElem::packed(&cite.key);
            };

            let mut elem = CiteElem::new(label);
            if let Some(supplement) = &cite.supplement {
                elem = elem.with_supplement(Some(cc(engine, supplement)));
            }
            if let Some(form) = &cite.form {
                elem = elem.with_form(match form.as_str() {
                    "prose" => Some(CitationForm::Prose),
                    "full" => Some(CitationForm::Full),
                    "author" => Some(CitationForm::Author),
                    "year" => Some(CitationForm::Year),
                    "none" => None,
                    _ => Some(CitationForm::Normal),
                });
            }
            elem.pack()
        }
        ExContent::Bibliography(bib) => {
            let Some(sources) = bibliography_sources(&bib.sources) else {
                return TextElem::packed("[bibliography: missing source]");
            };

            let derived = match Bibliography::load(engine.world, Spanned::new(sources, Span::detached())) {
                Ok(derived) => derived,
                Err(_) => return TextElem::packed("[bibliography: load failed]"),
            };

            let mut elem = BibliographyElem::new(derived).with_full(bib.full);
            if let Some(title) = &bib.title {
                elem = elem.with_title(Smart::Custom(Some(cc(engine, title))));
            }
            elem.pack()
        }
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
            let mut elem = match crate::world::get_image_source(&img.src) {
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
                parse_rel(r)
                    .map(|rel| Smart::Custom(rel * 2.0))
                    .unwrap_or(Smart::Auto)
            }).unwrap_or(Smart::Auto))
            .with_fill(opt_paint(c.fill.as_deref())).pack(),

        ExContent::Ellipse(el) => EllipseElem::new()
            .with_body(Some(cc(engine, &el.body)))
            .with_width(smart_rel(el.width.as_deref()))
            .with_height(smart_sizing(el.height.as_deref()))
            .with_fill(opt_paint(el.fill.as_deref())).pack(),

        ExContent::Line(l) => {
            let start = l.start.as_deref().and_then(parse_axes).unwrap_or(Axes::splat(Rel::zero()));
            let mut el = LineElem::new().with_start(start);
            if let Some(end) = &l.end { if let Some(e) = parse_axes(end) { el = el.with_end(Some(e)); } }
            if let Some(len) = &l.length { if let Some(r) = parse_rel(len) { el = el.with_length(r); } }
            if let Some(ang) = &l.angle { if let Some(a) = parse_angle(ang) { el = el.with_angle(a); } }
            if let Some(st) = &l.stroke { if let Some(s) = parse_stroke(st) { el = el.with_stroke(s); } }
            el.pack()
        }

        ExContent::Polygon(pg) => {
            let verts: Vec<Axes<Rel<Length>>> = pg.vertices.iter().filter_map(|v| parse_axes(v)).collect();
            let mut el = PolygonElem::new(verts).with_fill(opt_paint(pg.fill.as_deref()));
            if let Some(st) = &pg.stroke {
                if let Some(s) = parse_stroke(st) {
                    el = el.with_stroke(Smart::Custom(Some(s)));
                }
            }
            el.pack()
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

        ExContent::List(list) => {
            let items: Vec<typst::foundations::Packed<ListItem>> = list.children.iter().filter_map(|c| match c {
                ExContent::ListItem(li) => Some(typst::foundations::Packed::new(ListItem::new(cc(engine, &li.body)))),
                _ => None,
            }).collect();
            let mut elem = ListElem::new(items);
            elem.tight.set(list.tight);
            elem.pack()
        }
        ExContent::ListItem(li) => ListItem::new(cc(engine, &li.body)).pack(),

        ExContent::Enum(en) => {
            let items: Vec<typst::foundations::Packed<EnumItem>> = en.children.iter().filter_map(|c| match c {
                ExContent::EnumItem(ei) => {
                    let mut e = EnumItem::new(cc(engine, &ei.body));
                    if let Some(n) = ei.number { e.number.set(Smart::Custom(n as u64)); }
                    Some(typst::foundations::Packed::new(e))
                }
                _ => None,
            }).collect();
            let mut elem = EnumElem::new(items);
            elem.tight.set(en.tight);
            if let Some(start) = en.start { elem.start.set(Smart::Custom(start as u64)); }
            elem.pack()
        }
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
                let mut elem = typst::model::RefElem::new(lbl);
                if let Some(sup) = &r.supplement {
                    elem.supplement.set(Smart::Custom(Some(typst::model::Supplement::Content(cc(engine, sup)))));
                }
                elem.pack()
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
