defmodule Mix.Tasks.Freebsd.Pkg do
  @moduledoc "Generate FreeBSD package from mix release"

  use Mix.Task

  @shortdoc "Generates FreeBSD pkg files"
  def run(_) do
    config = Mix.Project.config() |> Keyword.get(:freebsd, [])

    prep_tmp()

    # elixir stuff
    manifest()
    stage()

    # FreeBSD stuff
    rc(config)
    plist()

    pkg()
  end

  defp pkg() do
    {_, 0} =
      System.cmd("pkg", [
        "create",
        "-M",
        manifest_file(),
        "-r",
        stage_dir(),
        "-p",
        "#{tmp_dir()}/pkg-plist"
      ])

    IO.puts("Wrote #{pkg_file()}")
  end

  defp manifest() do
    result = Jason.encode!(FreeBSD.pkg_manifest())
    File.write!(manifest_file(), result)
  end

  defp manifest_file(), do: "#{tmp_dir()}/+MANIFEST"

  defp rc(config) do
    etc_dir = "#{install_dir()}/etc"
    rc_dir = "#{etc_dir}/rc.d"
    rc_file = "#{rc_dir}/#{pkg_name()}"
    File.mkdir_p!(rc_dir)

    rc_result =
      template_file("rc.eex")
      |> EEx.eval_file(
        assigns: %{
          pkg_name: pkg_name(),
          bin_path: bin_path(),
          beam_path: beam_path(),
          conf_dir: conf_dir(),
          conf_dir_var: conf_dir_var(),
          daemon_flags: daemon_flags(config)
        }
      )

    File.write!(rc_file, rc_result)
    File.chmod!(rc_file, 0o755)
  end

  defp daemon_flags(config) do
    flags = []
    flags = if config[:user], do: ["-u #{config[:user]}"], else: flags
    Enum.join(flags, " ")
  end

  defp prep_tmp() do
    File.rm_rf!(tmp_dir())
    File.mkdir_p!(tmp_dir())
  end

  defp stage() do
    libexec_dir = "#{install_dir()}/libexec/#{pkg_name()}"
    File.mkdir_p!(libexec_dir)
    File.cp_r!(rel_dir(), libexec_dir)
  end

  defp plist() do
    plist_file = File.stream!("#{tmp_dir()}/pkg-plist")

    :ok =
      rel_files()
      |> Stream.map(&"#{&1}\n")
      |> Stream.into(plist_file)
      |> Stream.run()
  end

  defp stage_dir(), do: "#{tmp_dir()}/stage"

  defp install_dir(), do: "#{stage_dir()}#{FreeBSD.pkg_prefix()}"

  defp tmp_dir(), do: "tmp/freebsd"

  defp build_dir(), do: "_build/#{Mix.env()}"

  defp rel_dir(), do: "#{build_dir()}/rel/#{pkg_name()}"

  defp pkg_file(), do: "#{pkg_name()}-#{FreeBSD.pkg_version()}.pkg"

  defp bin_path(),
    do: rel_files() |> Enum.find(&String.ends_with?(&1, "/bin/#{pkg_name()}"))

  defp beam_path(), do: rel_files() |> Enum.find(&String.ends_with?(&1, "/bin/beam.smp"))

  defp rel_files do
    "#{stage_dir()}/**/*"
    |> Path.wildcard()
    |> Stream.filter(&Enum.member?([:regular, :symlink], File.lstat!(&1).type))
    |> Stream.map(&String.replace(&1, "#{stage_dir()}#{FreeBSD.pkg_prefix()}/", ""))
  end

  defp template_file(file),
    do: Application.app_dir(:freebsd, "priv/templates/freebsd.pkg/#{file}")

  defp pkg_name, do: FreeBSD.pkg_name() |> to_string()

  defp conf_dir, do: [FreeBSD.pkg_prefix(), "etc", pkg_name() <> ".d"] |> Enum.join("/")

  defp conf_dir_var, do: pkg_name() |> String.upcase()
end
