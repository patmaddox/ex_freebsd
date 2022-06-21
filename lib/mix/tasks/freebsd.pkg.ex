defmodule Mix.Tasks.Freebsd.Pkg do
  @moduledoc "Generate FreeBSD package from mix release"
  @requirements ["release"]

  use Mix.Task

  @shortdoc "Generates FreeBSD pkg files"
  def run(_) do
    prep_tmp()

    # elixir stuff
    manifest()
    stage()

    # FreeBSD stuff
    bin_script()
    rc()
    plist()

    pkg()
  end

  defp pkg() do
    System.cmd("pkg", [
      "create",
      "-M",
      manifest_file(),
      "-r",
      stage_dir(),
      "-p",
      "#{tmp_dir()}/pkg-plist",
      "-o",
      "freebsd"
    ])

    IO.puts("Wrote #{pkg_file()}")
  end

  defp manifest() do
    result = EEx.eval_file("freebsd/MANIFEST.eex")
    File.write!(manifest_file(), result)
  end

  defp manifest_file(), do: "#{tmp_dir()}/+MANIFEST"

  defp bin_script() do
    File.mkdir_p("#{install_dir()}/bin")

    File.ln_s!(
      "#{FreeBSD.pkg_prefix()}/libexec/#{FreeBSD.pkg_name()}/bin/#{FreeBSD.pkg_name()}",
      "#{install_dir()}/bin/#{FreeBSD.pkg_name()}"
    )
  end

  defp rc() do
    etc_dir = "#{install_dir()}/etc"
    rc_dir = "#{etc_dir}/rc.d"
    rc_file = "#{rc_dir}/#{FreeBSD.pkg_name()}"
    File.mkdir_p!(rc_dir)
    rc_result = EEx.eval_file("freebsd/rc.eex", assigns: %{pkg_name: FreeBSD.pkg_name()})
    File.write!(rc_file, rc_result)
    File.chmod!(rc_file, 0o755)

    conf_file = "#{etc_dir}/#{FreeBSD.pkg_name()}.conf.sample"
    conf_result = EEx.eval_file("freebsd/rc_conf.eex", assigns: %{pkg_name: FreeBSD.pkg_name()})
    File.write!(conf_file, conf_result)
    File.chmod!(conf_file, 0o640)
  end

  defp prep_tmp() do
    File.rm_rf!(tmp_dir())
    File.mkdir_p!(tmp_dir())
  end

  defp stage() do
    libexec_dir = "#{install_dir()}/libexec/#{FreeBSD.pkg_name()}"
    File.mkdir_p!(libexec_dir)
    File.cp_r!(rel_dir(), libexec_dir)
  end

  defp plist() do
    plist_file = File.stream!("#{tmp_dir()}/pkg-plist")

    :ok =
      "#{stage_dir()}/**/*"
      |> Path.wildcard()
      |> Stream.filter(&Enum.member?([:regular, :symlink], File.lstat!(&1).type))
      |> Stream.map(&String.replace(&1, "#{stage_dir()}#{FreeBSD.pkg_prefix()}/", ""))
      |> Stream.map(&"#{&1}\n")
      |> Stream.into(plist_file)
      |> Stream.run()
  end

  defp stage_dir(), do: "#{tmp_dir()}/stage"

  defp install_dir(), do: "#{stage_dir()}#{FreeBSD.pkg_prefix()}"

  defp tmp_dir(), do: "tmp/freebsd"

  defp build_dir(), do: "_build/#{Mix.env()}"

  defp rel_dir(), do: "#{build_dir()}/rel/#{FreeBSD.pkg_name()}"

  defp pkg_file(), do: "freebsd/#{FreeBSD.pkg_name()}-#{FreeBSD.pkg_version()}.pkg"
end
