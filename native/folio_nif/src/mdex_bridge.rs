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
                level: h.level as u8,
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
            })
        }

        NodeValue::List(_list) => {
            let items: Vec<ExContent> = node.children().map(|child| {
                ExContent::ListItem(ExListItem {
                    body: convert_children(child),
                })
            }).collect();
            ExContent::List(ExList {
                children: items,
                tight: true,
            })
        }

        NodeValue::SoftBreak => ExContent::Space(ExSpace {}),
        NodeValue::LineBreak => ExContent::Linebreak(ExLinebreak {}),
        NodeValue::ThematicBreak => ExContent::Pagebreak(ExPagebreak {}),

        NodeValue::Math(math) => {
            ExContent::Math(ExMath {
                content: math.literal.clone(),
                block: math.display_math,
            })
        }

        NodeValue::HtmlBlock(_) | NodeValue::HtmlInline(_) => {
            ExContent::Sequence(ExSequence { children: vec![] })
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
    let body_rows: Vec<ExContent> = vec![];
    let mut column_count = 1usize;

    for row in node.children() {
        if let NodeValue::TableRow(_header) = &row.data.borrow().value {
            for cell in row.children() {
                header_cells.push(ExContent::TableCell(ExTableCell {
                    body: convert_children(cell),
                    colspan: None,
                }));
            }
            column_count = column_count.max(header_cells.len());
        }
    }

    let children = if !header_cells.is_empty() {
        let mut result = vec![
            ExContent::TableHeader(ExTableHeader { children: header_cells }),
        ];
        result.extend(body_rows);
        result
    } else {
        body_rows
    };

    ExContent::Table(ExTable {
        num_columns: column_count,
        children,
    })
}
