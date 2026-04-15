# Folio

Print-quality PDF from Markdown + Elixir, powered by [Typst](https://typst.app).

## Usage

```elixir
defmodule MyApp.Report do
  use Folio

  def pdf(report) do
    ~MD"""
    # #{report.title}

    #{report.introduction}

    ## Key Findings

    #{table columns: [auto, 1 |> fr, auto] do
      table_header ["Metric", "Value", "Trend"]
      for f <- report.findings do
        table_row [f.metric, f.value, f.trend]
      end
    end}

    #{figure do
      image report.chart_path, width: 70 |> pct
      caption "Revenue over 12 months"
    end}

    Growth follows $x^2 + 1$ distribution.
    """p
  end
end
```

## Installation

```elixir
def deps do
  [
    {:folio, "~> 0.1.0"}
  ]
end
```

## License

MIT
