# Ported from Typst page, heading, and bibliography examples.
# Demonstrates page headers/footers, heading numbering, citations, and bibliography.
#
# Run: mix run examples/publishing.exs

use Folio

File.mkdir_p!("examples/output")
Folio.register_file("works.bib", File.read!("examples/works.bib"))

{:ok, pdf} =
  Folio.to_pdf(
    [
      heading(1, "Distributed Systems Notes"),
      text("Consensus protocols remain central to fault-tolerant systems. "),
      cite("lamport1998", supplement: "p. 140"),
      text(" provides the classic Paxos formulation."),
      heading(2, "Background"),
      text("Knuth's typography work remains essential for technical publishing. "),
      cite("knuth1984", form: "prose"),
      text(" is still widely referenced."),
      heading(2, "References in flow"),
      list([
        [text("Normal citation: "), cite("lamport1998")],
        [text("Author form: "), cite("knuth1984", form: "author")],
        [text("Year form: "), cite("knuth1984", form: "year")],
        [text("Full form: "), cite("lamport1998", form: "full")]
      ]),
      pagebreak(),
      heading(1, "Bibliography"),
      bibliography("works.bib", title: "References")
    ],
    styles: [
      Folio.Styles.page_size(width: 595, height: 842),
      Folio.Styles.page_margin(top: 48, right: 48, bottom: 56, left: 48),
      Folio.Styles.font_size(11),
      Folio.Styles.font_family(["Helvetica"]),
      Folio.Styles.page_header(
        align("center", [smallcaps("Folio Publishing Example")])
      ),
      Folio.Styles.page_footer(
        align("center", [text("Generated with Folio")])
      ),
      Folio.Styles.page_numbering("1"),
      Folio.Styles.heading_numbering("1."),
      Folio.Styles.heading_supplement("Chapter"),
      Folio.Styles.heading_bookmarked(true),
      Folio.Styles.heading_outlined(true),
      Folio.Styles.par_indent(18)
    ]
  )

File.write!("examples/output/publishing.pdf", pdf)
IO.puts("  publishing.pdf — #{byte_size(pdf)} bytes")
IO.puts("\nDone. See examples/output/")
