defmodule Folio.MixProject do
  use Mix.Project

  @version "0.2.2"
  @source_url "https://github.com/dannote/folio"

  def project do
    [
      app: :folio,
      version: @version,
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      elixirc_paths: elixirc_paths(Mix.env()),
      dialyzer: [
        plt_file: {:no_warn, "_build/dev/dialyxir_plt.plt"}
      ],

      # Hex
      name: "Folio",
      description: "Print-quality PDF from Markdown + Elixir, powered by Typst",
      source_url: @source_url,
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:rustler, "~> 0.37", optional: true},
      {:rustler_precompiled, "~> 0.8"},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_dna, "~> 1.3", only: [:dev, :test], runtime: false}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def cli do
    [preferred_envs: [ci: :test]]
  end

  defp package do
    [
      maintainers: ["Danila Poyarkov"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
      files: ~w(lib native/folio_nif/Cargo.toml native/folio_nif/Cargo.lock native/folio_nif/src
           vendor/typst/Cargo.toml vendor/typst/Cargo.lock vendor/typst/crates
           mix.exs README.md LICENSE.md CHANGELOG.md .rustler.toml
           checksum-Elixir.Folio.Native.exs),
      exclude_patterns: [~r{vendor/typst/crates/typst-cli}, ~r{vendor/typst/crates/typst-ide}]
    ]
  end

  defp aliases do
    [
      ci: [
        "compile --warnings-as-errors",
        "format --check-formatted",
        "credo --strict",
        "dialyzer",
        "test",
        "ex_dna"
      ]
    ]
  end
end
