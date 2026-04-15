use std::num::NonZeroUsize;

use ecow::{EcoString, eco_format};
use typst::foundations::{Content, NativeElement, Smart};
use typst::layout::{PagebreakElem, Sizing, TrackSizings};
use typst::model::{
    EmphElem, EnumItem, HeadingElem, ListItem, ParbreakElem, QuoteElem, StrongElem,
    TableChild, TableElem, TableHeader, TableItem, TableCell,
};
use typst::text::{LinebreakElem, RawContent, RawElem, SpaceElem, TextElem};

use crate::types::*;

/// Build a Typst Content tree from a list of ExContent nodes.
pub fn build_content(nodes: &[ExContent]) -> Content {
    let mut seq: Vec<Content> = Vec::new();

    for (i, node) in nodes.iter().enumerate() {
        if i > 0 && is_block(node) && is_block(&nodes[i - 1]) {
            seq.push(ParbreakElem::shared().clone());
        }
        seq.push(convert_node(node));
    }

    Content::sequence(seq)
}

fn is_block(node: &ExContent) -> bool {
    matches!(
        node,
        ExContent::Heading(_)
            | ExContent::Paragraph(_)
            | ExContent::List(_)
            | ExContent::Enum(_)
            | ExContent::Figure(_)
            | ExContent::Table(_)
            | ExContent::Raw(ExRaw { block: true, .. })
            | ExContent::Quote(_)
            | ExContent::Block(_)
            | ExContent::Columns(_)
            | ExContent::Pagebreak(_)
            | ExContent::Math(ExMath { block: true, .. })
    )
}

fn convert_node(node: &ExContent) -> Content {
    match node {
        ExContent::Text(t) => TextElem::packed(&t.text),

        ExContent::Space(_) => SpaceElem::shared().clone(),

        ExContent::Heading(h) => {
            let body = convert_children(&h.body);
            let depth = NonZeroUsize::new(h.level as usize)
                .unwrap_or(NonZeroUsize::MIN);
            HeadingElem::new(body).with_depth(depth).pack()
        }

        ExContent::Paragraph(p) => convert_children(&p.body),

        ExContent::Strong(s) => {
            StrongElem::new(convert_children(&s.body)).pack()
        }

        ExContent::Emph(e) => {
            EmphElem::new(convert_children(&e.body)).pack()
        }

        ExContent::Strike(s) => convert_children(&s.body),

        ExContent::Image(_img) => TextElem::packed("[image]"),

        ExContent::Figure(fig) => convert_children(&fig.body),

        ExContent::Table(tbl) => {
            let num_cols = if tbl.num_columns > 0 { tbl.num_columns } else { 1 };
            let columns = TrackSizings(
                std::iter::repeat_with(|| Sizing::Auto)
                    .take(num_cols)
                    .collect()
            );

            let mut children: Vec<TableChild> = Vec::new();

            for child in &tbl.children {
                match child {
                    ExContent::TableHeader(th) => {
                        let cells: Vec<TableItem> = th.children.iter()
                            .filter_map(|c| match c {
                                ExContent::TableCell(tc) => {
                                    Some(TableItem::Cell(
                                        typst::foundations::Packed::new(
                                            TableCell::new(convert_children(&tc.body))
                                        )
                                    ))
                                }
                                _ => None,
                            })
                            .collect();
                        let header = TableHeader::new(cells);
                        children.push(TableChild::Header(typst::foundations::Packed::new(header)));
                    }
                    ExContent::TableRow(tr) => {
                        for cell_node in &tr.children {
                            if let ExContent::TableCell(tc) = cell_node {
                                let cell = TableCell::new(convert_children(&tc.body));
                                children.push(TableChild::Item(TableItem::Cell(
                                    typst::foundations::Packed::new(cell)
                                )));
                            }
                        }
                    }
                    ExContent::TableCell(tc) => {
                        let cell = TableCell::new(convert_children(&tc.body));
                        children.push(TableChild::Item(TableItem::Cell(
                            typst::foundations::Packed::new(cell)
                        )));
                    }
                    _ => {}
                }
            }

            TableElem::new(children)
                .with_columns(columns)
                .pack()
        }

        ExContent::TableHeader(_) => Content::empty(),
        ExContent::TableRow(_) => Content::empty(),
        ExContent::TableCell(tc) => convert_children(&tc.body),

        ExContent::Columns(cols) => convert_children(&cols.body),

        ExContent::Pagebreak(_) => PagebreakElem::new().pack(),

        ExContent::Parbreak(_) => ParbreakElem::shared().clone(),
        ExContent::Linebreak(_) => LinebreakElem::shared().clone(),

        ExContent::Math(m) => {
            TextElem::packed(if m.block {
                eco_format!("$${}$$", &m.content)
            } else {
                eco_format!("${}", &m.content)
            })
        }

        ExContent::Link(link) => TextElem::packed(&link.url),

        ExContent::Raw(raw) => {
            let content = RawContent::Text(EcoString::from(&raw.text));
            let mut elem = RawElem::new(content).with_block(raw.block);
            if let Some(lang) = &raw.lang {
                elem = elem.with_lang(Some(EcoString::from(lang)));
            }
            elem.pack()
        }

        ExContent::Quote(q) => {
            QuoteElem::new(convert_children(&q.body)).pack()
        }

        ExContent::List(list) => {
            let items: Vec<Content> = list
                .children
                .iter()
                .map(|c| convert_node(c))
                .collect();
            Content::sequence(items)
        }

        ExContent::ListItem(li) => {
            ListItem::new(convert_children(&li.body)).pack()
        }

        ExContent::Enum(en) => {
            let items: Vec<Content> = en
                .children
                .iter()
                .map(|c| convert_node(c))
                .collect();
            Content::sequence(items)
        }

        ExContent::EnumItem(ei) => {
            let mut elem = EnumItem::new(convert_children(&ei.body));
            if let Some(n) = ei.number {
                elem.number.set(Smart::Custom(n as u64));
            }
            elem.pack()
        }

        ExContent::Label(_) => Content::empty(),
        ExContent::Ref(r) => TextElem::packed(&r.target),

        ExContent::Align(a) => convert_children(&a.body),
        ExContent::Block(b) => convert_children(&b.body),

        ExContent::Sequence(seq) => convert_children(&seq.children),
    }
}

fn convert_children(nodes: &[ExContent]) -> Content {
    let items: Vec<Content> = nodes.iter().map(|n| convert_node(n)).collect();
    Content::sequence(items)
}
