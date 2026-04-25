use Folio

items = [
  %{desc: "Folio NIF Binary",    qty: 1, price: 49},
  %{desc: "Rustler Integration", qty: 1, price: 29},
  %{desc: "Typst Math Engine",   qty: 1, price: 19},
]

total = items |> Enum.map(& &1.price) |> Enum.sum()

accent = "#6C5CE7"
light  = "#F8F7FF"
dark   = "#2D3436"
muted  = "#636E72"
pad    = "28pt"

invoice = [
  # ── Header band ──
  raw_typst("""
  #block(width: 100%, inset: (x: #{pad}, y: 20pt), fill: rgb("#{accent}"))[
    #set text(fill: white)
    #grid(columns: (1fr, auto),
      [#text(size: 24pt, weight: "bold")[INVOICE]],
      align(right)[
        #text(size: 10pt)[
          \\#FOLIO-001 \\ April 25, 2026 \\ Due: May 25, 2026
        ]
      ]
    )
  ]
  """),

  vspace("20pt"),

  # ── Addresses ──
  raw_typst("""
  #block(inset: (x: #{pad}))[
    #set text(size: 9pt)
    #grid(columns: (1fr, 1fr), column-gutter: 24pt,
      [
        #text(fill: rgb("#{muted}"), weight: "bold", size: 7pt, tracking: 0.5pt)[FROM] \\
        #text(weight: "bold")[Folio Labs] \\
        hello\\@folio.dev \\
        Beam VM, The Internet
      ],
      [
        #text(fill: rgb("#{muted}"), weight: "bold", size: 7pt, tracking: 0.5pt)[TO] \\
        #text(weight: "bold")[Acme Corp] \\
        orders\\@acme.example \\
        742 Evergreen Terrace
      ]
    )
  ]
  """),

  vspace("16pt"),

  # ── Line items table ──
  raw_typst("""
  #block(inset: (x: #{pad}))[
    #set text(size: 9pt)
    #table(
      columns: (1fr, auto, auto, auto),
      stroke: none,
      column-gutter: 0pt,
      inset: (x: 10pt, y: 8pt),
      fill: (_, row) => if row == 0 { rgb("#{accent}") } else if calc.odd(row) { rgb("#{light}") },
      table.header(
        text(fill: white, weight: "bold")[Description],
        text(fill: white, weight: "bold")[Qty],
        text(fill: white, weight: "bold")[Price],
        text(fill: white, weight: "bold")[Amount],
      ),
      #{items |> Enum.map(fn %{desc: d, qty: q, price: p} -> "[#{d}], [#{q}], [\\$#{p}], [\\$#{q * p}]," end) |> Enum.join("\n      ")}
    )
  ]
  """),

  vspace("6pt"),

  # ── Total ──
  raw_typst("""
  #block(inset: (x: #{pad}))[
    #set text(size: 9pt)
    #grid(columns: (1fr, auto),
      [],
      align(right)[
        #grid(columns: (auto, auto), column-gutter: 12pt, row-gutter: 4pt, align: (right, right),
          [Subtotal:], [\\$#{total}.00],
          [Tax (0%):], [\\$0.00],
        )
        #v(2pt)
        #line(length: 140pt, stroke: 0.5pt + rgb("#{muted}"))
        #v(2pt)
        #text(size: 14pt, weight: "bold", fill: rgb("#{accent}"))[Total: \\$#{total}.00]
      ]
    )
  ]
  """),

  vspace("14pt"),

  # ── Math proof ──
  raw_typst("""
  #block(inset: (x: #{pad}))[
    #block(width: 100%, inset: (x: 16pt, y: 10pt), fill: rgb("#{light}"), radius: 4pt)[
      #set text(size: 8.5pt, fill: rgb("#{muted}"))
      #align(center)[
        Verified by Typst: #h(6pt)
        #text(fill: rgb("#{dark}"))[$#{items |> Enum.map(& &1.price) |> Enum.map(&to_string/1) |> Enum.join(" + ")} = #{total}$]
      ]
    ]
  ]
  """),

  vspace("10pt"),

  # ── Footer ──
  raw_typst("""
  #block(inset: (x: #{pad}))[
    #line(length: 100%, stroke: 0.5pt + rgb("#{muted}"))
    #v(6pt)
    #set text(size: 7.5pt, fill: rgb("#{muted}"))
    #grid(columns: (1fr, auto),
      [Payment via wire transfer. Reference: FOLIO-001],
      [Generated with *Folio* — Elixir → Typst → PDF]
    )
  ]
  """),
]

{:ok, png} = Folio.to_png(invoice, styles: [
  page_size(width: 420, height: 470),
  page_margin(top: 0, right: 0, bottom: 16, left: 0),
  font_family(["Inter", "Helvetica Neue", "Helvetica"]),
], dpi: 3.0)

File.mkdir_p!("examples/output")
File.write!("examples/output/tweet_invoice.png", hd(png))
IO.puts("Wrote tweet_invoice.png — #{byte_size(hd(png))} bytes")
