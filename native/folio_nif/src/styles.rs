use typst::foundations::{Content, Styles, StyleChain};
use typst_library::text::TextElem;
use typst_library::layout::PageElem;

use crate::types::*;

/// Build a Styles map from a list of ExStyleRule.
pub fn build_styles(rules: &[ExStyleRule]) -> Styles {
    let mut styles = Styles::new();

    for rule in rules {
        match rule {
            ExStyleRule::SetRule(r) => {
                apply_set_rule(&mut styles, r);
            }
            ExStyleRule::ShowSetRule(r) => {
                // Show-set rules need to be attached differently
                // They apply when a matching element is shown
                // TODO: implement show-set rules
            }
            ExStyleRule::ShowRule(r) => {
                // Show-transform rules modify how elements are rendered
                // TODO: implement show rules
            }
        }
    }

    styles
}

fn apply_set_rule(styles: &mut Styles, rule: &ExSetRule) {
    match rule.element.as_str() {
        "page" => apply_page_set(styles, &rule.fields),
        "text" => apply_text_set(styles, &rule.fields),
        "par" => apply_par_set(styles, &rule.fields),
        "heading" => apply_heading_set(styles, &rule.fields),
        _ => {}
    }
}

fn apply_page_set(styles: &mut Styles, fields: &[(String, ExValue)]) {
    for (key, value) in fields {
        match key.as_str() {
            "paper" => {
                if let ExValue::Str(paper) = value {
                    styles.set(PageElem::paper, Some(paper.as_str().into()));
                }
            }
            "margin" => {
                // TODO: convert ExValue to margin
            }
            "numbering" => {
                if let ExValue::Str(pattern) = value {
                    styles.set(PageElem::numbering, Some(pattern.clone().into()));
                }
            }
            _ => {}
        }
    }
}

fn apply_text_set(styles: &mut Styles, fields: &[(String, ExValue)]) {
    for (key, value) in fields {
        match key.as_str() {
            "font" => {
                if let ExValue::Str(font) = value {
                    styles.set(TextElem::font, vec![font.as_str().into()]);
                }
            }
            "size" => {
                if let Some(length) = ex_value_to_length(value) {
                    styles.set(TextElem::size, length);
                }
            }
            "weight" => {
                if let Some(weight) = ex_value_to_weight(value) {
                    styles.set(TextElem::weight, weight);
                }
            }
            _ => {}
        }
    }
}

fn apply_par_set(styles: &mut Styles, fields: &[(String, ExValue)]) {
    for (key, value) in fields {
        match key.as_str() {
            "justify" => {
                if let ExValue::Bool(b) = value {
                    styles.set(typst_library::layout::ParElem::justify, *b);
                }
            }
            _ => {}
        }
    }
}

fn apply_heading_set(styles: &mut Styles, fields: &[(String, ExValue)]) {
    // Heading styles are set on the HeadingElem
    for (key, value) in fields {
        match key.as_str() {
            _ => {}
        }
    }
}

// --- Value conversions ---

fn ex_value_to_length(val: &ExValue) -> Option<typst::layout::Abs> {
    match val {
        ExValue::Pt(n) => Some(typst::layout::Abs::pt(*n)),
        ExValue::Cm(n) => Some(typst::layout::Abs::cm(*n)),
        ExValue::Mm(n) => Some(typst::layout::Abs::mm(*n)),
        _ => None,
    }
}

fn ex_value_to_weight(val: &ExValue) -> Option<typst::text::FontWeight> {
    match val {
        ExValue::Str(w) => typst::text::FontWeight::from_number(w.parse::<u16>().ok()?),
        ExValue::Int(n) => typst::text::FontWeight::from_number(*n as u16),
        _ => None,
    }
}
