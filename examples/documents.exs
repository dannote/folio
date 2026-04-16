# Ported from Typst's tutorial/gallery document patterns
# Full multi-page documents demonstrating Folio's capabilities
#
# Run: mix run examples/documents.exs

use Folio

File.mkdir_p!("examples/output")

# ── Invoice (business document pattern) ───────────────────────────────────────

{:ok, pdf} = Folio.to_pdf([
  heading(1, "INVOICE"),
  vspace("12pt"),
  columns(2, do: [
    [
      strong("Acme Corporation"),
      text("123 Business Ave, Suite 100"),
      text("New York, NY 10001"),
    ],
    [
      align("right", [
        text("Invoice #INV-2024-001"),
        text("Date: 2024-01-15"),
        text("Due: 2024-02-15"),
      ]),
    ],
  ]),
  divider(),
  vspace("8pt"),
  strong("Bill To:"),
  text("Client Corp, 456 Client St, Los Angeles, CA 90001"),
  vspace("12pt"),
  table([gutter: "4pt"], do: [
    table_header([
      table_cell(strong("Description")),
      table_cell(strong("Qty")),
      table_cell(strong("Rate")),
      table_cell(strong("Amount")),
    ]),
    table_row([table_cell("Design"), table_cell("40"), table_cell("$150"), table_cell("$6,000")]),
    table_row([table_cell("Development"), table_cell("80"), table_cell("$125"), table_cell("$10,000")]),
    table_row([table_cell("Testing"), table_cell("20"), table_cell("$100"), table_cell("$2,000")]),
    table_row([table_cell("Management"), table_cell("30"), table_cell("$110"), table_cell("$3,300")]),
  ]),
  vspace("8pt"),
  align("right", [
    text("Subtotal: $21,300.00"),
    text("Tax (8%): $1,704.00"),
    strong("Total: $23,004.00"),
  ]),
  vspace("20pt"),
  divider(),
  vspace("8pt"),
  smallcaps("Payment terms: Net 30 days"),
  footnote(text("Reference invoice number on all payments.")),
], styles: [
  Folio.Styles.page_size(width: 595, height: 842),
  Folio.Styles.font_size(11),
  Folio.Styles.font_family(["Helvetica"]),
  Folio.Styles.page_numbering("1"),
])
File.write!("examples/output/invoice.pdf", pdf)
IO.puts("  invoice.pdf — #{byte_size(pdf)} bytes")

# ── Technical Report (multi-section with TOC, math, tables) ──────────────────

{:ok, pdf} = Folio.to_pdf([
  # Title page
  vspace("140pt"),
  align("center", [
    heading(1, "Distributed Consensus:\nA Comparative Analysis"),
    vspace("20pt"),
    text("Dr. Jane Smith"),
    vspace("4pt"),
    smallcaps("University of Technology — March 2024"),
  ]),

  pagebreak(),

  # Table of contents
  outline(title: "Table of Contents"),
  pagebreak(),

  # Section 1
  heading(1, "Introduction"),
  text("Distributed consensus algorithms enable a collection of processes to agree on a value, even in the presence of failures. This report compares three major approaches: Paxos, Raft, and PBFT."),

  heading(2, "Problem Statement"),
  text("We model a distributed system as n processes where at most f may fail. Consensus requires three properties: agreement, validity, and termination."),

  # Section 2
  heading(1, "Mathematical Framework"),
  text("The correctness condition can be expressed as:"),
  vspace("4pt"),
  text("$$forall i, j in text(\"correct\"): lim_(t -> oo) |v_i(t) - v_j(t)| = 0$$"),
  vspace("4pt"),
  text("where $v_i(t)$ denotes the value at process $i$ at time $t$."),

  text("The throughput relationship:"),
  vspace("4pt"),
  text("$$T = (n * msg_size) / (2 * RTT + t_\"process\")$$"),

  # Section 3
  heading(1, "Experimental Results"),

  table([gutter: "4pt"], do: [
    table_header([
      table_cell(strong("Algorithm")),
      table_cell(strong("3 nodes")),
      table_cell(strong("5 nodes")),
      table_cell(strong("7 nodes")),
      table_cell(strong("9 nodes")),
    ]),
    table_row([table_cell("Paxos"), table_cell("2.1 ms"), table_cell("3.4 ms"), table_cell("4.8 ms"), table_cell("6.2 ms")]),
    table_row([table_cell("Raft"), table_cell("1.8 ms"), table_cell("2.9 ms"), table_cell("4.1 ms"), table_cell("5.5 ms")]),
    table_row([table_cell("PBFT"), table_cell("4.5 ms"), table_cell("7.2 ms"), table_cell("11.3 ms"), table_cell("16.1 ms")]),
  ]),

  heading(2, "Analysis"),
  text("Raft demonstrates the lowest latency due to its simplified leader election. PBFT shows quadratic growth due to all-to-all communication."),

  heading(2, "Key Findings"),
  list([
    "Raft: best for crash-fault environments",
    "Paxos: strongest theoretical guarantees",
    "PBFT: necessary for Byzantine faults but expensive",
  ]),

  # Section 4
  heading(1, "Conclusion"),
  text("Raft provides the best balance of simplicity and performance for most practical deployments. For environments requiring Byzantine fault tolerance, PBFT remains the standard despite its overhead."),

  heading(2, "Glossary"),
  term_list([
    {"Consensus", "Agreement among distributed processes"},
    {"Byzantine Fault", "A process that may behave arbitrarily"},
    {"Quorum", "A majority subset of processes"},
  ]),
], styles: [
  Folio.Styles.page_size(width: 595, height: 842),
  Folio.Styles.font_size(11),
  Folio.Styles.font_family(["Helvetica"]),
  Folio.Styles.text_color("#222222"),
  Folio.Styles.page_numbering("1"),
])
File.write!("examples/output/technical_report.pdf", pdf)
IO.puts("  technical_report.pdf — #{byte_size(pdf)} bytes")

# ── Design Portfolio (visual showcase) ────────────────────────────────────────

{:ok, pdf} = Folio.to_pdf([
  # Cover page with colored header bar
  vspace("200pt"),
  rect(fill: "#2C3E50", width: "100%", height: "80pt",
    body: align("center", [
      heading(1, "Design Portfolio"),
      text("Jane Doe — 2024"),
    ])),

  pagebreak(),

  # Color palette
  heading(1, "Color Palette"),
  vspace("8pt"),
  columns(4, do: [
    rect(fill: "#E74C3C", width: "100%", height: "50pt"),
    rect(fill: "#3498DB", width: "100%", height: "50pt"),
    rect(fill: "#2ECC71", width: "100%", height: "50pt"),
    rect(fill: "#F39C12", width: "100%", height: "50pt"),
  ]),
  vspace("12pt"),

  # Typography
  heading(1, "Typography"),
  columns(2, do: [
    [
      heading(2, "Scale"),
      text("Body text. "),
      strong("Bold. "),
      emph("Italic. "),
      underline("Underline. "),
      strike("Strikethrough. "),
      vspace("4pt"),
      smallcaps("Smallcaps."),
      vspace("4pt"),
      text("x"),
      superscript("2"),
      text(" and H"),
      subscript("2"),
      text("O"),
    ],
    [
      heading(2, "Highlights"),
      highlight("Important.", fill: "#FFF3CD"), vspace("4pt"),
      highlight("Critical.", fill: "#F8D7DA"), vspace("4pt"),
      highlight("Success.", fill: "#D4EDDA"),
    ],
  ]),
  vspace("12pt"),

  # Shapes
  heading(1, "Shapes"),
  columns(3, do: [
    rect(fill: "#3498DB", width: "80pt", height: "60pt"),
    circle(fill: "#E74C3C", radius: "30pt"),
    ellipse(fill: "#2ECC71", width: "100pt", height: "60pt"),
  ]),

  pagebreak(),

  # Two-column project description
  heading(1, "Project: Brand Identity"),
  columns(2, do: [
    [
      heading(2, "Objective"),
      text("Create a cohesive visual identity communicating innovation and reliability."),
      heading(2, "Approach"),
      text("Deep-dive into the competitive landscape, identifying visual communication gaps."),
    ],
    [
      heading(2, "Results"),
      text("Brand recognition increased 47% in A/B testing."),
      heading(2, "Deliverables"),
      term_list([
        {"Logo", "Primary, secondary, and icon variants"},
        {"Colors", "6-color accessible palette"},
        {"Typography", "Heading and body pairings"},
      ]),
    ],
  ]),

  vspace("20pt"),
  divider(),
  align("center", smallcaps("Confidential — Do Not Distribute")),
], styles: [
  Folio.Styles.page_size(width: 595, height: 842),
  Folio.Styles.font_size(11),
  Folio.Styles.font_family(["Helvetica"]),
  Folio.Styles.page_numbering("1"),
])
File.write!("examples/output/portfolio.pdf", pdf)
IO.puts("  portfolio.pdf — #{byte_size(pdf)} bytes")

# ── Markdown-Driven Document ─────────────────────────────────────────────────

{:ok, pdf} = ~MD"""
# Markdown-Driven Document

This entire document is written in Markdown with embedded Elixir DSL calls.

## Features

- **Bold**, *italic*, ~~strikethrough~~
- Lists, tables, code blocks
- Math: $E = m c^2$ inline and block:

$$integral_0^1 x^2 dif x = 1/3$$

## Table

| Feature | Status |
|---------|--------|
| PDF export | Done |
| SVG export | Done |
| PNG export | Done |
| Math | Done |
| Tables | Done |

## Code

```elixir
Folio.to_pdf("Hello, World!")
|> then(&File.write!("out.pdf", elem(&1, 1)))
```

> This is a blockquote from Markdown.

That's it — pure Markdown, no Typst syntax exposed.
"""p

File.write!("examples/output/markdown_doc.pdf", pdf)
IO.puts("  markdown_doc.pdf — #{byte_size(pdf)} bytes")

IO.puts("\nDone. See examples/output/")
