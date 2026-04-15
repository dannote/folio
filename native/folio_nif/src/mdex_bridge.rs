use comrak::nodes::{AstNode, NodeValue, Sourcepos};
use ecow::EcoString;

use crate::types::*;

/// Convert comrak AST children to a vector of ExContent.
pub fn convert_children<'a>(node: &'a AstNode<'a>, arena: &'a typed_arena::Arena<comrak::nodes::AstNode<'a>>) -> Vec<ExContent> {
    node.children().map(|child| convert_node(child, arena)).collect()
}

/// Convert a single comrak AST node to ExContent.
fn convert_node<'a>(node: &'a AstNode<'a>, arena: &'a typed_arena::Arena<comrak::nodes::AstNode<'a>>) -> ExContent {
    match &node.data.borrow().value {
        // --- Document ---
        NodeValue::Document => {
            let children = convert_children(node, arena);
            if children.len() == 1 {
                children.into_iter().next().unwrap()
            } else {
                ExContent::Sequence(ExSequence { children })
            }
        }

        // --- Headings ---
        NodeValue::Heading(h) => {
            ExContent::Heading(ExHeading {
                level: h.level as u8,
                body: convert_children(node, arena),
            })
        }

        // --- Paragraphs ---
        NodeValue::Paragraph => {
            ExContent::Paragraph(ExParagraph {
                body: convert_children(node, arena),
            })
        }

        // --- Text ---
        NodeValue::Text(literal) => {
            ExContent::Text(ExText { text: literal.clone() })
        }

        // --- Strong / Emph ---
        NodeValue::Strong => {
            ExContent::Strong(ExStrong {
                body: convert_children(node, arena),
            })
        }
        NodeValue::Emph => {
            ExContent::Emph(ExEmph {
                body: convert_children(node, arena),
            })
        }

        // --- Links ---
        NodeValue::Link(link) => {
            ExContent::Link(ExLink {
                url: link.url.clone(),
                body: convert_children(node, arena),
            })
        }

        // --- Images ---
        NodeValue::Image(img) => {
            ExContent::Image(ExImage {
                src: img.url.clone(),
                width: None,
                height: None,
                fit: None,
            })
        }

        // --- Code ---
        NodeValue::Code(code) => {
            ExContent::Raw(ExRaw {
                text: code.literal.clone(),
                lang: None,
                block: false,
            })
        }

        // --- Code Blocks ---
        NodeValue::CodeBlock(block) => {
            ExContent::Raw(ExRaw {
                text: block.literal.clone(),
                lang: if block.info.is_empty() { None } else { Some(block.info.clone()) },
                block: true,
            })
        }

        // --- Block Quote ---
        NodeValue::BlockQuote => {
            ExContent::Quote(ExQuote {
                body: convert_children(node, arena),
                block: true,
                attribution: None,
            })
        }

        // --- Lists ---
        NodeValue::List(list) => {
            let children: Vec<ExContent> = node.children().map(|child| {
                ExContent::ListItem(ExListItem {
                    body: convert_children(child, arena),
                })
            }).collect();

            let list_type = if list.list_type == comrak::nodes::ListType::Bullet {
                ExListType::Bullet
            } else {
                ExListType::Ordered
            };

            ExContent::List(ExList {
                children,
                list_type,
                tight: list.tight,
                start: list.start as u32,
                delimiter: match list.delimiter {
                    comrak::nodes::ListDelimType::Period => ExListDelim::Period,
                    comrak::nodes::ListDelimType::Paren => ExListDelim::Paren,
                },
                bullet_char: list.bullet_char.to_string(),
                marker_offset: list.marker_offset as u32,
                padding: list.padding as u32,
            })
        }

        // --- Soft Break ---
        NodeValue::SoftBreak => ExContent::Space(ExSpace),

        // --- Line Break ---
        NodeValue::LineBreak => ExContent::Linebreak(ExLinebreak),

        // --- Thematic Break ---
        NodeValue::ThematicBreak => {
            // Could be pagebreak or horizontal rule depending on context
            ExContent::Pagebreak(ExPagebreak { weak: false })
        }

        // --- Tables ---
        NodeValue::Table(_) => {
            convert_table(node, arena)
        }

        // --- HTML blocks / inline (pass through or skip) ---
        NodeValue::HtmlBlock(block) => {
            // HTML blocks are not directly representable in Typst
            // We could try to parse simple HTML tables or skip
            ExContent::Sequence(ExSequence { children: vec![] })
        }
        NodeValue::HtmlInline(html) => {
            ExContent::Sequence(ExSequence { children: vec![] })
        }

        // --- Task items ---
        NodeValue::TaskItem(symbol) => {
            let body = convert_children(node, arena);
            // Render as a checkbox + content
            let checkbox = if *symbol == '[' {
                ExContent::Text(ExText { text: "☐ ".into() })
            } else {
                ExContent::Text(ExText { text: "☑ ".into() })
            };
            ExContent::Sequence(ExSequence {
                children: vec![checkbox, ExContent::Sequence(ExSequence { children: body })],
            })
        }

        // --- Footnote ---
        NodeValue::FootnoteDefinition(name) => {
            ExContent::Sequence(ExSequence { children: vec![] })
        }

        // --- Strikethrough ---
        NodeValue::Strikethrough => {
            // Typst doesn't have native strikethrough in markup
            // but has the strike function
            let body = convert_children(node, arena);
            ExContent::Strike(ExStrike { body })
        }

        // --- Math (comrak extension) ---
        NodeValue::Math(math) => {
            ExContent::Math(ExMath {
                content: math.literal.clone(),
                block: false,
            })
        }
        NodeValue::DisplayMath(math) => {
            ExContent::Math(ExMath {
                content: math.literal.clone(),
                block: true,
            })
        }

        // --- Escaped ---
        NodeValue::Escaped => {
            let text = node.data.borrow().content.clone().unwrap_or_default();
            ExContent::Text(ExText { text })
        }

        // --- Unknown / unsupported ---
        _ => ExContent::Sequence(ExSequence { children: vec![] }),
    }
}

/// Convert a GFM table to Typst table content.
fn convert_table<'a>(node: &'a AstNode<'a>, arena: &'a typed_arena::Arena<comrak::nodes::AstNode<'a>>) -> ExContent {
    let mut rows: Vec<Vec<ExContent>> = vec![];
    let mut column_count = 0;

    for row_node in node.children() {
        if let NodeValue::TableRow(header) = &row_node.data.borrow().value {
            let mut cells: Vec<ExContent> = vec![];
            for cell_node in row_node.children() {
                cells.push(ExContent::TableCell(ExTableCell {
                    body: convert_children(cell_node, arena),
                    colspan: None,
                    rowspan: None,
                    align: None,
                }));
            }
            column_count = column_count.max(cells.len());
            rows.push(cells);
        }
    }

    // Split into header and body rows
    let (header_rows, body_rows) = rows.split_at_mut(
        rows.iter().position(|r| r.is_empty()).unwrap_or(rows.len()).min(1)
    );

    let mut children: Vec<ExContent> = vec![];

    // Header
    if let Some(header) = header_rows.first() {
        children.push(ExContent::TableHeader(ExTableHeader {
            children: header.clone(),
        }));
    }

    // Body rows
    for row in body_rows {
        children.push(ExContent::TableRow(ExTableRow {
            children: row.clone(),
        }));
    }

    let columns: Vec<ExValue> = (0..column_count).map(|_| ExValue::Auto).collect();

    ExContent::Table(ExTable {
        columns,
        rows: vec![],
        children,
        stroke: None,
        gutter: None,
        align: None,
    })
}
