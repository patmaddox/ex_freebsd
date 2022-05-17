defmodule Mix.Tasks.Freebsd.Gen.Pkg do
  @moduledoc "Generate pkg template files"

  use Mix.Task

  alias Mix.Generator

  def run(_) do
    Generator.create_directory("freebsd")
    ["MANIFEST.eex", "pkg-descr.eex", "rc.eex"]
    |> Enum.each(&Generator.copy_file("priv/templates/freebsd.gen.pkg/#{&1}", "freebsd/#{&1}"))
  end
end
