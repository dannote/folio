use std::num::NonZeroUsize;

use ecow::EcoString;
use typst::engine::Engine;
use typst::foundations::{Content, NativeElement, Smart};
use typst::layout::{PagebreakElem, Sizing, TrackSizings};
use typst::model::{
    EmphElem, EnumItem, FigureCaption, FigureElem, HeadingElem, ListItem, ParbreakElem,
    QuoteElem, StrongElem, TableChild, TableElem, TableHeader, TableItem, TableCell,
};
use typst::text::{LinebreakElem, RawContent, RawElem, SpaceElem, StrikeElem, TextElem};
use typst::layout::{AlignElem, BlockElem, ColumnsElem};
use typst::model::{LinkElem, LinkTarget};

use crate::types::ExContent;
use crate::world::FolioWorld;

pub fn build_content(engine: &mut Engine, nodes: &[ExContent]) -> Content {
    let mut seq: Vec<Content> = Vec::new();
    for (i, node) in nodes.iter().enumerate() {
        if i > 0 && is_block(node) && is_block(&nodes[i - 1]) {
            seq.push(ParbreakElem::shared().clone());
        }
        seq.push(convert_node(engine, node));
    }
    Content::sequence(seq)
}

fn is_block(node: &ExContent) -> bool {
    match node {
        ExContent::Heading(_)
        | ExContent::Paragraph(_)
        | ExContent::List(_)
        | ExContent::Enum(_)
        | ExContent::Figure(_)
        | ExContent::Table(_)
        | ExContent::Quote(_)
        | ExContent::Block(_)
        | ExContent::Columns(_)
        | ExContent::Pagebreak(_) => true,
        ExContent::Raw(r) => r.block,
        ExContent::Math(m) => m.block,
        _ => false,
    }
}

fn convert_node(engine: &mut Engine, node: &ExContent) -> Content {
    match node {
        ExContent::Text(t) => TextElem::packed(&t.text),
        ExContent::Space(_) => SpaceElem::shared().clone(),

        ExContent::Heading(h) => {
            let body = convert_children(engine, &h.body);
            let depth = NonZeroUsize::new(h.level as usize).unwrap_or(NonZeroUsize::MIN);
            HeadingElem::new(body).with_depth(depth).pack()
        }

        ExContent::Paragraph(p) => convert_children(engine, &p.body),

        ExContent::Strong(s) => StrongElem::new(convert_children(engine, &s.body)).pack(),
        ExContent::Emph(e) => EmphElem::new(convert_children(engine, &e.body)).pack(),

        ExContent::Strike(s) => StrikeElem::new(convert_children(engine, &s.body)).pack(),

        ExContent::Image(img) => FolioWorld::make_image(engine, &img.src),

        ExContent::Figure(fig) => {
            let body = convert_children(engine, &fig.body);
            let mut elem = FigureElem::new(body);
            if let Some(caption_nodes) = &fig.caption {
                let caption_body = convert_children(engine, caption_nodes);
                elem = elem.with_caption(Some(typst::foundations::Packed::new(
                    FigureCaption::new(caption_body),
                )));
            }
            elem.pack()
        }

        ExContent::Table(tbl) => convert_table(engine, tbl),

        ExContent::TableHeader(_) | ExContent::TableRow(_) => Content::empty(),
        ExContent::TableCell(tc) => convert_children(engine, &tc.body),

        ExContent::Columns(cols) => {
            let count = NonZeroUsize::new(cols.count as usize).unwrap_or(NonZeroUsize::MIN);
            let body = convert_children(engine, &cols.body);
            ColumnsElem::new(body).with_count(count).pack()
        }

        ExContent::Pagebreak(pb) => PagebreakElem::new().with_weak(pb.weak).pack(),
        ExContent::Parbreak(_) => ParbreakElem::shared().clone(),
        ExContent::Linebreak(_) => LinebreakElem::shared().clone(),

        ExContent::Math(m) => FolioWorld::eval_math(engine, &m.content, m.block),

        ExContent::Link(link) => {
            let dest = typst::model::Destination::Url(
                typst::model::Url::new(&link.url).unwrap_or_else(|_| {
                    typst::model::Url::new("about:blank").unwrap()
                }),
            );
            let body = if link.body.is_empty() {
                TextElem::packed(&link.url)
            } else {
                convert_children(engine, &link.body)
            };
            LinkElem::new(LinkTarget::Dest(dest), body).pack()
        }

        ExContent::Raw(raw) => {
            let content = RawContent::Text(EcoString::from(&raw.text));
            let mut elem = RawElem::new(content).with_block(raw.block);
            if let Some(lang) = &raw.lang {
                elem = elem.with_lang(Some(EcoString::from(lang)));
            }
            elem.pack()
        }

        ExContent::Quote(q) => {
            let body = convert_children(engine, &q.body);
            let mut elem = QuoteElem::new(body).with_block(q.block);
            if let Some(attr_nodes) = &q.attribution {
                let attr = convert_children(engine, attr_nodes);
                elem = elem.with_attribution(Some(typst::model::Attribution::Content(attr)));
            }
            elem.pack()
        }

        ExContent::List(list) => Content::sequence(
            list.children
                .iter()
                .map(|c| convert_node(engine, c))
                .collect::<Vec<_>>(),
        ),
        ExContent::ListItem(li) => ListItem::new(convert_children(engine, &li.body)).pack(),

        ExContent::Enum(en) => Content::sequence(
            en.children
                .iter()
                .map(|c| convert_node(engine, c))
                .collect::<Vec<_>>(),
        ),
        ExContent::EnumItem(ei) => {
            let mut elem = EnumItem::new(convert_children(engine, &ei.body));
            if let Some(n) = ei.number {
                elem.number.set(Smart::Custom(n as u64));
            }
            elem.pack()
        }

        ExContent::Label(label) => {
            // Attach label as a field on the preceding content.
            // In Typst, labels are attached via Content::labelled().
            // For standalone labels, we create a labelled empty content.
            if let Some(lbl) = typst::foundations::Label::new(
                typst::utils::PicoStr::intern(&label.name),
            ) {
                Content::empty().labelled(lbl)
            } else {
                Content::empty()
            }
        }

        ExContent::Ref(r) => {
            if let Some(lbl) = typst::foundations::Label::new(
                typst::utils::PicoStr::intern(&r.target),
            ) {
                typst::model::RefElem::new(lbl).pack()
            } else {
                TextElem::packed(&r.target)
            }
        }

        ExContent::Align(a) => {
            let alignment = parse_alignment(&a.alignment);
            let body = convert_children(engine, &a.body);
            AlignElem::new(body).with_alignment(alignment).pack()
        }

        ExContent::Block(b) => {
            let body = convert_children(engine, &b.body);
            BlockElem::new()
                .with_body(Some(typst::layout::BlockBody::Content(body)))
                .pack()
        }

        ExContent::Sequence(seq) => convert_children(engine, &seq.children),
    }
}

fn parse_alignment(s: &str) -> typst::layout::Alignment {
    use typst::layout::Alignment;
    match s {
        "left" => Alignment::LEFT,
        "center" => Alignment::CENTER,
        "right" => Alignment::RIGHT,
        "top" => Alignment::TOP,
        "bottom" => Alignment::BOTTOM,
        _ => Alignment::LEFT,
    }
}

fn convert_table(engine: &mut Engine, tbl: &crate::types::ExTable) -> Content {
    let num_cols = count_columns(tbl);
    let columns = TrackSizings(
        std::iter::repeat_with(|| Sizing::Auto)
            .take(num_cols)
            .collect(),
    );
    let mut children: Vec<TableChild> = Vec::new();

    for child in &tbl.children {
        match child {
            ExContent::TableHeader(th) => {
                let cells: Vec<TableItem> = th
                    .children
                    .iter()
                    .filter_map(|c| match c {
                        ExContent::TableCell(tc) => Some(TableItem::Cell(
                            typst::foundations::Packed::new(TableCell::new(convert_children(
                                engine, &tc.body,
                            ))),
                        )),
                        _ => None,
                    })
                    .collect();
                children.push(TableChild::Header(typst::foundations::Packed::new(
                    TableHeader::new(cells),
                )));
            }
            ExContent::TableRow(tr) => {
                for cell_node in &tr.children {
                    if let ExContent::TableCell(tc) = cell_node {
                        children.push(TableChild::Item(TableItem::Cell(
                            typst::foundations::Packed::new(TableCell::new(convert_children(
                                engine, &tc.body,
                            ))),
                        )));
                    }
                }
            }
            ExContent::TableCell(tc) => {
                children.push(TableChild::Item(TableItem::Cell(
                    typst::foundations::Packed::new(TableCell::new(convert_children(
                        engine, &tc.body,
                    ))),
                )));
            }
            _ => {}
        }
    }

    TableElem::new(children).with_columns(columns).pack()
}

/// Count table columns from header or first row.
fn count_columns(tbl: &crate::types::ExTable) -> usize {
    for child in &tbl.children {
        match child {
            ExContent::TableHeader(th) => return th.children.len().max(1),
            ExContent::TableRow(tr) => return tr.children.len().max(1),
            _ => {}
        }
    }
    1
}

fn convert_children(engine: &mut Engine, nodes: &[ExContent]) -> Content {
    Content::sequence(
        nodes
            .iter()
            .map(|n| convert_node(engine, n))
            .collect::<Vec<_>>(),
    )
}
