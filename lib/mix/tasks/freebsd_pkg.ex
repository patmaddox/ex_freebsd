defmodule Mix.Tasks.Freebsd.Pkg do
  @moduledoc "Generate FreeBSD package from mix release"
  @requirements ["release"]

  use Mix.Task

  @shortdoc "Generates FreeBSD pkg files"
  def run(_) do
    prep_tmp()
    manifest()
    pkg_descr()
    stage()
    rc()
    plist()
    pkg()
  end

  defp pkg() do
    System.cmd("pkg", [
      "create",
      "-m",
      tmp_dir(),
      "-r",
      stage_dir(),
      "-p",
      "#{tmp_dir()}/pkg-plist",
      "-o",
      "freebsd"
    ])
  end

  defp manifest() do
    result = EEx.eval_file("freebsd/MANIFEST.eex", assigns: FreeBSD.config())
    File.write!("#{tmp_dir()}/+MANIFEST", result)
  end

  defp pkg_descr() do
    result = EEx.eval_file("freebsd/pkg-descr.eex", assigns: FreeBSD.config())
    File.write!("#{tmp_dir()}/+DESC", result)
  end

  defp rc() do
    rc_dir = "#{install_dir()}/etc/rc.d"
    rc_file = "#{rc_dir}/#{FreeBSD.port_name()}"
    File.mkdir_p!(rc_dir)
    result = EEx.eval_file("freebsd/rc.eex", assigns: FreeBSD.config())
    File.write!(rc_file, result)
    File.chmod!(rc_file, 0o755)
  end

  defp prep_tmp() do
    File.rm_rf!(tmp_dir())
    File.mkdir_p!(tmp_dir())
  end

  defp stage() do
    libexec_dir = "#{install_dir()}/libexec/#{FreeBSD.port_name()}"
    File.mkdir_p!(libexec_dir)
    File.cp_r!(rel_dir(), libexec_dir)
  end

  defp plist() do
    plist_file = File.stream!("#{tmp_dir()}/pkg-plist")

    :ok =
      "#{stage_dir()}/**/*"
      |> Path.wildcard()
      |> Stream.filter(&File.regular?(&1))
      |> Stream.map(&String.replace(&1, "#{stage_dir()}#{FreeBSD.pkg_prefix()}/", ""))
      |> Stream.map(&"#{&1}\n")
      |> Stream.into(plist_file)
      |> Stream.run()
  end

  defp stage_dir(), do: "#{tmp_dir()}/stage"

  defp install_dir(), do: "#{stage_dir()}#{FreeBSD.pkg_prefix()}"

  defp tmp_dir(), do: "tmp/freebsd"

  defp build_dir(), do: "_build/#{Mix.env()}"

  defp rel_dir(), do: "#{build_dir()}/rel/#{FreeBSD.port_name()}"
end
