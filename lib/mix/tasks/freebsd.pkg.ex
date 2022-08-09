defmodule Mix.Tasks.Freebsd.Pkg do
  @moduledoc "Generate FreeBSD package from mix release"

  use Mix.Task

  @shortdoc "Generates FreeBSD pkg files"
  def run(_) do
    config = Mix.Project.config() |> Keyword.fetch!(:freebsd)

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
    rc_file = "#{rc_dir}/#{FreeBSD.pkg_name()}"
    File.mkdir_p!(rc_dir)

    rc_result =
      FreeBSD.template_file("rc.eex")
      |> EEx.eval_file(
        assigns: %{
          pkg_name: FreeBSD.pkg_name(),
          bin_path: bin_path(),
          beam_path: beam_path(),
          conf_dir: FreeBSD.conf_dir(),
          conf_dir_var: FreeBSD.conf_dir_var(),
          daemon_flags: daemon_flags(config),
          pkg_user: FreeBSD.pkg_user()
        }
      )

    File.write!(rc_file, rc_result)
    File.chmod!(rc_file, 0o740)
  end

  defp daemon_flags(%{user: user}), do: "-u #{user}"
  defp daemon_flags(_), do: nil

  defp prep_tmp() do
    File.rm_rf!(tmp_dir())
    File.mkdir_p!(tmp_dir())
  end

  defp stage do
    libexec_dir = "#{install_dir()}/libexec/#{FreeBSD.pkg_name()}"
    File.mkdir_p!(libexec_dir)
    File.cp_r!(rel_dir(), libexec_dir)
    make_share_files()
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

  defp rel_dir(), do: "#{build_dir()}/rel/#{FreeBSD.pkg_name()}"

  defp pkg_file(), do: "#{FreeBSD.pkg_name()}-#{FreeBSD.pkg_version()}.pkg"

  defp bin_path(),
    do: rel_files() |> Enum.find(&String.ends_with?(&1, "/bin/#{FreeBSD.pkg_name()}"))

  defp beam_path(), do: rel_files() |> Enum.find(&String.ends_with?(&1, "/bin/beam.smp"))

  defp rel_files do
    "#{stage_dir()}/**/*"
    |> Path.wildcard()
    |> Stream.filter(&Enum.member?([:regular, :symlink], File.lstat!(&1).type))
    |> Stream.map(&String.replace(&1, "#{stage_dir()}#{FreeBSD.pkg_prefix()}/", ""))
  end

  defp make_share_files do
    share_dir = "#{install_dir()}/share/#{FreeBSD.pkg_name()}"
    File.mkdir_p!(share_dir)

    env_sample_contents = """
    # Environment variables defined here will be available to your application.
    # DATABASE_URL="ecto://username:password@host/database"
    """

    env_sample_file = "#{share_dir}/#{FreeBSD.env_file_name()}.sample"
    File.write!(env_sample_file, env_sample_contents)
    File.chmod!(env_sample_file, 0o644)
  end
end
