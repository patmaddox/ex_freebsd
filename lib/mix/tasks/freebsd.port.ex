defmodule Mix.Tasks.Freebsd.Port do
  @moduledoc "Generate FreeBSD port files: `mix help freebsd`"

  use Mix.Task

  @shortdoc "Generates FreeBSD port files"
  def run(_) do
    result = EEx.eval_file("freebsd/Makefile.eex", assigns: FreeBSD.config())
    File.write!("freebsd/Makefile", result)
  end
end
