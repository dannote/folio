defmodule Folio.MixProject do
  use Mix.Project

  @version "0.1.0"
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

      # Docs
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
      {:rustler, "~> 0.37"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      maintainers: ["dannote"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
      files: ~w(lib native/folio_nif/Cargo.toml native/folio_nif/src mix.exs README.md LICENSE.md .rustler.toml)
    ]
  end

  defp aliases do
    []
  end
end
