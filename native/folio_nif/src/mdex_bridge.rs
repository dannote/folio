use comrak::nodes::{AstNode, NodeValue};

use crate::types::*;

/// Convert all children of a comrak node into ExContent.
pub fn convert_children<'a>(node: &'a AstNode<'a>) -> Vec<ExContent> {
    node.children().map(convert_node).collect()
}

/// Convert a single comrak AST node to ExContent.
fn convert_node<'a>(node: &'a AstNode<'a>) -> ExContent {
    match &node.data.borrow().value {
        NodeValue::Document => {
            let children = convert_children(node);
            if children.len() == 1 {
                children.into_iter().next().unwrap()
            } else {
                ExContent::Sequence(ExSequence { children })
            }
        }

        NodeValue::Heading(h) => {
            ExContent::Heading(ExHeading {
                level: h.level,
                body: convert_children(node),
            })
        }

        NodeValue::Paragraph => {
            ExContent::Paragraph(ExParagraph {
                body: convert_children(node),
            })
        }

        NodeValue::Text(literal) => {
            ExContent::Text(ExText { text: literal.to_string() })
        }

        NodeValue::Strong => {
            ExContent::Strong(ExStrong {
                body: convert_children(node),
            })
        }

        NodeValue::Emph => {
            ExContent::Emph(ExEmph {
                body: convert_children(node),
            })
        }

        NodeValue::Strikethrough => {
            ExContent::Strike(ExStrike {
                body: convert_children(node),
            })
        }

        NodeValue::Link(link) => {
            ExContent::Link(ExLink {
                url: link.url.clone(),
                body: convert_children(node),
            })
        }

        NodeValue::Image(img) => {
            ExContent::Image(ExImage {
                src: img.url.clone(),
                width: None,
                height: None,
                fit: None,
            })
        }

        NodeValue::Code(code) => {
            ExContent::Raw(ExRaw {
                text: code.literal.clone(),
                lang: None,
                block: false,
            })
        }

        NodeValue::CodeBlock(block) => {
            ExContent::Raw(ExRaw {
                text: block.literal.clone(),
                lang: if block.info.is_empty() { None } else { Some(block.info.clone()) },
                block: true,
            })
        }

        NodeValue::BlockQuote => {
            ExContent::Quote(ExQuote {
                body: convert_children(node),
                block: true,
                attribution: None,
            })
        }

        NodeValue::List(list) => {
            let items: Vec<ExContent> = node.children().map(|child| {
                convert_children(child).into_iter().next()
                    .unwrap_or(ExContent::Space(ExSpace {}))
            }).collect();

            match list.list_type {
                comrak::nodes::ListType::Ordered => ExContent::Enum(ExEnum {
                    children: items.into_iter().map(|item| match item {
                        ExContent::Paragraph(p) => ExContent::EnumItem(ExEnumItem { body: p.body, number: None }),
                        other => ExContent::EnumItem(ExEnumItem { body: vec![other], number: None }),
                    }).collect(),
                    tight: list.tight,
                    start: if list.start == 0 { None } else { Some(list.start as u32) },
                }),
                _ => ExContent::List(ExList {
                    children: items.into_iter().map(|item| match item {
                        ExContent::Paragraph(p) => ExContent::ListItem(ExListItem { body: p.body }),
                        other => ExContent::ListItem(ExListItem { body: vec![other] }),
                    }).collect(),
                    tight: list.tight,
                    marker: None,
                }),
            }
        }

        NodeValue::SoftBreak => ExContent::Space(ExSpace {}),
        NodeValue::LineBreak => ExContent::Linebreak(ExLinebreak {}),
        NodeValue::ThematicBreak => ExContent::Divider(ExDivider {}),

        NodeValue::Math(math) => {
            ExContent::Math(ExMath {
                content: math.literal.clone(),
                block: math.display_math,
            })
        }

        NodeValue::HtmlBlock(_) | NodeValue::HtmlInline(_) => {
            ExContent::Sequence(ExSequence { children: vec![] })
        }

        NodeValue::DescriptionList => {
            let items: Vec<ExContent> = node.children().map(|item_node| {
                let mut term = vec![];
                let mut descriptions = vec![];
                for child in item_node.children() {
                    match &child.data.borrow().value {
                        NodeValue::DescriptionTerm => {
                            term = convert_children(child);
                        }
                        NodeValue::DescriptionDetails => {
                            let desc = convert_children(child);
                            descriptions.push(ExContent::TermItem(ExTermItem {
                                term: term.clone(),
                                description: desc,
                            }));
                        }
                        _ => {}
                    }
                }
                ExContent::Sequence(ExSequence { children: descriptions })
            }).collect();

            let term_items: Vec<ExContent> = items.iter().flat_map(|c| match c {
                ExContent::Sequence(s) => s.children.clone(),
                other => vec![other.clone()],
            }).collect();

            ExContent::TermList(ExTermList {
                children: term_items,
                tight: false,
            })
        }

        NodeValue::DescriptionItem(_) | NodeValue::DescriptionTerm | NodeValue::DescriptionDetails => {
            convert_children(node).into_iter().next()
                .unwrap_or(ExContent::Space(ExSpace {}))
        }

        NodeValue::Table(_aligns) => {
            convert_table(node)
        }

        _ => ExContent::Sequence(ExSequence { children: vec![] }),
    }
}

/// Convert a GFM table.
fn convert_table<'a>(node: &'a AstNode<'a>) -> ExContent {
    let mut header_cells: Vec<ExContent> = vec![];
    let mut body_rows: Vec<ExContent> = vec![];
    let mut column_count = 1usize;

    for row in node.children() {
        if let NodeValue::TableRow(is_header) = &row.data.borrow().value {
            let cells: Vec<ExContent> = row.children().map(|cell| {
        ExContent::TableCell(ExTableCell {
                    body: convert_children(cell),
                    colspan: None,
                    rowspan: None,
                    align: None,
                })
            }).collect();
            column_count = column_count.max(cells.len());

            if *is_header {
                header_cells = cells;
            } else {
                body_rows.push(ExContent::TableRow(ExTableRow { children: cells }));
            }
        }
    }

    let mut children: Vec<ExContent> = vec![];
    if !header_cells.is_empty() {
        children.push(ExContent::TableHeader(ExTableHeader { children: header_cells }));
    }
    children.extend(body_rows);

    ExContent::Table(ExTable {
        columns: None,
        rows: None,
        children,
        stroke: None,
        gutter: None,
        align: None,
    })
}
