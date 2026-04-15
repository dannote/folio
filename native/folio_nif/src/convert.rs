use std::num::NonZeroUsize;

use ecow::EcoString;
use typst::foundations::{Content, Styles, StyleChain};
use typst::layout::{Abs, Em, Fr, Ratio, Rel, TrackSizing, TrackSizings};
use typst::text::{TextElem, FontWeight};
use typst_library::model::{
    HeadingElem, StrongElem, EmphElem, ListItem, EnumItem, QuoteElem,
};
use typst_library::layout::{
    PagebreakElem, ColumnsElem, ParbreakElem, LinebreakElem, SpaceElem,
};
use typst_library::visualize::ImageElem;
use typst_library::model::FigureElem;
use typst_library::layout::grid::{GridElem};

use crate::types::*;
use crate::world::TypstexWorld;

/// Convert a slice of ExContent into a Typst Content sequence.
pub fn ex_sequence_to_content(nodes: &[ExContent], world: &TypstexWorld) -> Content {
    let items: Vec<Content> = nodes.iter()
        .map(|n| ex_to_content(n, world))
        .collect();
    Content::sequence(items)
}

/// Convert a single ExContent to a Typst Content.
pub fn ex_to_content(node: &ExContent, world: &TypstexWorld) -> Content {
    match node {
        ExContent::Text(t) => TextElem::packed(&t.text),

        ExContent::Space(_) => SpaceElem::shared().clone(),

        ExContent::Heading(h) => {
            let body = ex_sequence_to_content(&h.body, world);
            HeadingElem::new(body)
                .with_depth(NonZeroUsize::new(h.level as _).unwrap_or(NonZeroUsize::ONE))
                .pack()
        }

        ExContent::Paragraph(p) => ex_sequence_to_content(&p.body, world),

        ExContent::Strong(s) => StrongElem::new(ex_sequence_to_content(&s.body, world)).pack(),

        ExContent::Emph(e) => EmphElem::new(ex_sequence_to_content(&e.body, world)).pack(),

        ExContent::Image(img) => {
            // TODO: resolve image from world, create ImageElem
            Content::empty()
        }

        ExContent::Figure(fig) => {
            let body = ex_sequence_to_content(&fig.body, world);
            let mut elem = FigureElem::new(body);
            // TODO: set caption, placement, etc.
            elem.pack()
        }

        ExContent::Table(t) => {
            let columns: Vec<TrackSizing> = t.columns.iter()
                .map(ex_to_track_sizing)
                .collect();
            let children = ex_sequence_to_content(&t.children, world);
            // TODO: construct TableElem properly with columns and children
            Content::empty()
        }

        ExContent::TableHeader(th) => {
            // TODO: construct TableHeader
            ex_sequence_to_content(&th.children, world)
        }

        ExContent::TableRow(tr) => {
            ex_sequence_to_content(&tr.children, world)
        }

        ExContent::TableCell(tc) => {
            // TODO: construct TableCell with colspan/rowspan/align
            ex_sequence_to_content(&tc.body, world)
        }

        ExContent::Columns(c) => {
            let body = ex_sequence_to_content(&c.body, world);
            ColumnsElem::new(body)
                .with_count(c.count)
                .pack()
        }

        ExContent::Pagebreak(pb) => {
            let mut elem = PagebreakElem::new();
            if pb.weak {
                elem = elem.with_weak(true);
            }
            elem.pack()
        }

        ExContent::Parbreak(_) => ParbreakElem::shared().clone(),
        ExContent::Linebreak(_) => LinebreakElem::shared().clone(),

        ExContent::Math(m) => {
            // Parse math string via typst_syntax::parse_math()
            // and evaluate to Content
            crate::math::parse_math_to_content(&m.content, m.block)
        }

        ExContent::Bibliography(bib) => {
            // TODO: construct Bibliography
            Content::empty()
        }

        ExContent::Link(link) => {
            // TODO: construct LinkElem
            Content::empty()
        }

        ExContent::Raw(raw) => {
            use typst_library::text::{RawElem, RawContent};
            let content = RawContent::Text(raw.text.clone().into());
            let mut elem = RawElem::new(content).with_block(raw.block);
            if let Some(lang) = &raw.lang {
                elem = elem.with_lang(Some(lang.clone().into()));
            }
            elem.pack()
        }

        ExContent::Quote(q) => {
            let body = ex_sequence_to_content(&q.body, world);
            QuoteElem::new(body).with_block(q.block).pack()
        }

        ExContent::List(list) => {
            let items: Vec<Content> = list.children.iter()
                .filter_map(|c| match c {
                    ExContent::ListItem(li) => Some(
                        ListItem::new(ex_sequence_to_content(&li.body, world)).pack()
                    ),
                    _ => None,
                })
                .collect();
            Content::sequence(items)
        }

        ExContent::ListItem(li) => {
            ListItem::new(ex_sequence_to_content(&li.body, world)).pack()
        }

        ExContent::Enum(list) => {
            let items: Vec<Content> = list.children.iter()
                .filter_map(|c| match c {
                    ExContent::EnumItem(ei) => {
                        let mut elem = EnumItem::new(ex_sequence_to_content(&ei.body, world));
                        if let Some(num) = ei.number {
                            elem = elem.with_number(Some(Smart::Custom(num)));
                        }
                        Some(elem.pack())
                    }
                    _ => None,
                })
                .collect();
            Content::sequence(items)
        }

        ExContent::EnumItem(ei) => {
            let mut elem = EnumItem::new(ex_sequence_to_content(&ei.body, world));
            if let Some(num) = ei.number {
                elem = elem.with_number(Some(Smart::Custom(*num)));
            }
            elem.pack()
        }

        ExContent::Label(l) => {
            // Labels are attached via .labelled() on content
            // This needs special handling at the parent level
            Content::empty()
        }

        ExContent::Ref(r) => {
            // TODO: construct RefElem
            Content::empty()
        }

        ExContent::Align(a) => {
            // TODO: construct align()
            ex_sequence_to_content(&a.body, world)
        }

        ExContent::Block(b) => {
            // TODO: construct block()
            ex_sequence_to_content(&b.body, world)
        }

        ExContent::Pad(p) => {
            // TODO: construct pad()
            ex_sequence_to_content(&p.body, world)
        }

        ExContent::Grid(g) => {
            // TODO: construct GridElem
            ex_sequence_to_content(&g.children, world)
        }

        ExContent::Stack(s) => {
            // TODO: construct StackElem
            ex_sequence_to_content(&s.children, world)
        }

        ExContent::Strike(s) => {
            // TODO: construct strike() function call
            ex_sequence_to_content(&s.body, world)
        }

        ExContent::Sequence(seq) => ex_sequence_to_content(&seq.children, world),
    }
}

fn ex_to_track_sizing(val: &ExValue) -> TrackSizing {
    match val {
        ExValue::Auto => TrackSizing::Auto,
        ExValue::Fr(n) => TrackSizing::Fr(Fr::new(*n)),
        ExValue::Pt(n) => TrackSizing::Rel(Rel::absolute(Abs::pt(*n))),
        ExValue::Cm(n) => TrackSizing::Rel(Rel::absolute(Abs::cm(*n))),
        ExValue::Mm(n) => TrackSizing::Rel(Rel::absolute(Abs::mm(*n))),
        ExValue::Em(n) => TrackSizing::Rel(Rel::new(Ratio::zero(), Em::new(*n))),
        ExValue::Pct(n) => TrackSizing::Rel(Rel::ratio(Ratio::new(*n / 100.0))),
        _ => TrackSizing::Auto,
    }
}

use typst::utils::Smart;
