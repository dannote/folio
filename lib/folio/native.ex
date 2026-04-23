defmodule Folio.Native do
  @moduledoc false

  alias Folio.Content
  alias Folio.Styles

  version = Mix.Project.config()[:version]
  source_root = Path.expand("../..", __DIR__)

  local_test_build =
    Mix.env() in [:dev, :test] and
      File.exists?(Path.join(source_root, "test/test_helper.exs")) and
      File.dir?(Path.join(source_root, ".git"))

  use RustlerPrecompiled,
    otp_app: :folio,
    crate: :folio_nif,
    base_url: "https://github.com/dannote/folio/releases/download/v#{version}",
    force_build: local_test_build or System.get_env("FOLIO_BUILD") in ["1", "true"],
    targets: ~w(
      aarch64-apple-darwin
      aarch64-unknown-linux-gnu
      x86_64-apple-darwin
      x86_64-unknown-linux-gnu
      x86_64-unknown-linux-musl
    ),
    version: version

  @spec parse_markdown(String.t()) :: [Content.t()]
  def parse_markdown(_markdown), do: :erlang.nif_error(:nif_not_loaded)

  @spec compile_pdf([Content.t()], [Styles.rule()], %{String.t() => binary()}) :: binary()
  def compile_pdf(_content, _styles, _files), do: :erlang.nif_error(:nif_not_loaded)

  @spec compile_svg([Content.t()], [Styles.rule()], %{String.t() => binary()}) :: [String.t()]
  def compile_svg(_content, _styles, _files), do: :erlang.nif_error(:nif_not_loaded)

  @spec compile_png([Content.t()], [Styles.rule()], %{String.t() => binary()}, float()) :: [
          binary()
        ]
  def compile_png(_content, _styles, _files, _dpi), do: :erlang.nif_error(:nif_not_loaded)

  @spec register_file(String.t(), binary()) :: :ok
  def register_file(_path, _data), do: :erlang.nif_error(:nif_not_loaded)

  @spec unregister_file(String.t()) :: :ok
  def unregister_file(_path), do: :erlang.nif_error(:nif_not_loaded)
end
