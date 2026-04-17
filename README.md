# Folio

Print-quality PDF/SVG/PNG from Markdown + Elixir, powered by [Typst](https://typst.app)'s layout engine via Rustler NIF.

[![Hex.pm](https://img.shields.io/hexpm/v/folio.svg)](https://hex.pm/packages/folio)
[![Docs](https://img.shields.io/badge/docs-hex.pm-blue)](https://hexdocs.pm/folio)

## Why Folio

### Data-Driven Documents at Runtime

Typst reads static files. Folio builds content trees from live Elixir data — Ecto queries, API responses, GenServer state. A Phoenix app generates PDFs from the same data it renders in HTML, with zero intermediate files:

```elixir
def invoice_pdf(order) do
  ~MD"""
  # Invoice #{order.number}

  #{table([gutter: "4pt"], do: [
    table_header([table_cell("Item"), table_cell("Qty"), table_cell("Price")]),
    for item <- order.line_items do
      table_row([table_cell(item.name), table_cell("#{item.quantity}"), table_cell(Money.to_string(item.price))])
    end
  ])}
  """p
end
```

### Composable Document Fragments

DSL functions return plain structs — document pieces are first-class Elixir values. Build reusable components as regular functions, pattern-match on them, store them, pipe them:

```elixir
defmodule Reports.Components do
  use Folio

  def kpi_card(label, value, trend) do
    block([above: "12pt", below: "12pt"], do: [
      strong(label),
      parbreak(),
      text("#{value} (#{trend})"),
    ])
  end
end
```

### No Typst Language, No Typst Parser, No Typst Evaluator

Folio constructs Typst content trees directly in Rust and feeds them straight to the layout engine. It bypasses Typst's parser, AST, and evaluation VM entirely:

- **No template injection** — there's no string template to inject into
- **No syntax errors** — content is structurally valid by construction
- **Smaller attack surface** — the Typst evaluator (file I/O, package imports, plugin loading) is never invoked
- **Faster for programmatic documents** — skipping parse + eval stages

### Elixir-Native Concurrency for Batch Generation

With Typst CLI, generating 10,000 invoices means 10,000 process spawns. With Folio on dirty schedulers:

```elixir
orders
|> Task.async_stream(
  fn order -> Folio.to_pdf(build_invoice(order)) end,
  max_concurrency: System.schedulers_online()
)
|> Stream.each(fn {:ok, pdf} -> upload(pdf) end)
|> Stream.run()
```

Fonts and layout data are loaded once and shared across compilations.

## Quick start

```elixir
def deps do
  [{:folio, "~> 0.1"}]
end
```

```elixir
use Folio

# Markdown → PDF
{:ok, pdf} = Folio.to_pdf("# Hello\n\n**Bold** and $x^2$ math.")

# ~MD sigil with p modifier → {:ok, binary}
{:ok, pdf} = ~MD"""
# Report

Some **bold** content with inline $E = m c^2$ math.

| Metric | Value |
|--------|-------|
| A      | 1     |
| B      | 2     |
"""p

# DSL → PDF
{:ok, pdf} = Folio.to_pdf([
  heading(1, "Hello"),
  text("Normal "),
  strong("bold"),
  text(" and "),
  emph("italic"),
])

# Export formats
{:ok, pdf} = Folio.to_pdf("# Hello")          # PDF binary
{:ok, svgs} = Folio.to_svg("# Hello")         # one SVG per page
{:ok, pngs} = Folio.to_png("# Hello")         # one PNG per page
{:ok, pngs} = Folio.to_png("# Hello", dpi: 3) # higher resolution
```

Full API documentation at [hexdocs.pm/folio](https://hexdocs.pm/folio).

## License

MIT — see [LICENSE.md](LICENSE.md)
