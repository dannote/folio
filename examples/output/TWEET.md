# Tweet

## Text

Folio — print-quality PDF/SVG/PNG from Elixir data, powered by Typst via Rustler NIF.

Documents are Elixir values: for-comprehensions become table rows, math renders via Typst, grid layouts compose. No templates, no external processes, no injection surface.

{:ok, pdf} = Folio.to_pdf(invoice) ↓

## Code snippet (for second image / alt text)

```elixir
use Folio

items = [
  %{desc: "Folio NIF Binary",    qty: 1, price: 49},
  %{desc: "Rustler Integration", qty: 1, price: 29},
  %{desc: "Typst Math Engine",   qty: 1, price: 19},
]

total = items |> Enum.map(& &1.price) |> Enum.sum()

invoice = [
  rect(width: "100%", fill: "#6C5CE7",
    body: grid(columns: ["1fr", "auto"], do: [
      grid_cell(strong("INVOICE")),
      grid_cell(align(:right, "#FOLIO-001"))
    ])
  ),

  table(columns: ["1fr", "auto", "auto", "auto"], stroke: "none",
    do: [
      table_header(["Description", "Qty", "Price", "Amount"]),
      for %{desc: d, qty: q, price: p} <- items do
        table_row([d, "#{q}", "$#{p}", "$#{q * p}"])
      end
    ]
  ),

  align(:right, strong("Total: $#{total}")),
  math("49 + 29 + 19 = 97"),
]

{:ok, pdf} = Folio.to_pdf(invoice)
```

## Images

1. `tweet_invoice.png` — the rendered output (attach to tweet)
