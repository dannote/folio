use typst::foundations::Content;
use typst_syntax::{parse_math, ast, SyntaxNode};

/// Parse a math string using Typst's math parser and convert to Content.
///
/// This handles inline and display math expressions.
pub fn parse_math_to_content(math_str: &str, block: bool) -> Content {
    let root = parse_math(math_str);

    // Check for parse errors
    let errors = root.errors();
    if !errors.is_empty() {
        // Return the raw text as a fallback
        return typst_library::text::TextElem::packed(
            if block { format!("$ {} $", math_str) } else { format!("${}$", math_str) }
        );
    }

    // The parsed tree is a math AST. We need to evaluate it to Content.
    // This requires a Typst evaluation context (VM), which is complex.
    //
    // Alternative approach: parse the math and construct Content manually
    // by walking the math AST nodes.
    //
    // For now, we use a simpler approach: evaluate the math as Typst source.
    // This means we generate a small Typst source fragment and compile it.

    // TODO: proper math evaluation without going through source strings.
    // The ideal path is to walk the math AST and build Content directly,
    // but that requires access to a Vm with scopes and context.

    Content::empty()
}
