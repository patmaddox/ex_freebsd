defmodule Mix.Tasks.Freebsd.Pkg do
  @moduledoc "Generate FreeBSD package from mix release"

  use Mix.Task

  @shortdoc "Generates FreeBSD pkg files"
  def run(_) do
    result = EEx.eval_file("freebsd/Manifest.eex", assigns: FreeBSD.config())
    File.write!("freebsd/+Manifest", result)
  end
end
