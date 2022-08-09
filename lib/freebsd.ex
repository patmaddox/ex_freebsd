defmodule FreeBSD do
  @moduledoc """
  `mix.exs` config values that will be assigned to the EEX templates when
  building the package.
  """

  def pkg_manifest do
    pkg_name = pkg_name()

    %{
      name: pkg_name,
      version: pkg_version(),
      origin: "devel/#{pkg_name}",
      comment: pkg_comment(),
      www: pkg_www(),
      maintainer: pkg_maintainer(),
      prefix: pkg_prefix(),
      desc: pkg_description(),
      scripts: %{
        "post-install" => "/usr/local/libexec/#{pkg_name}/bin/post-install",
        "pre-deinstall" => "/usr/local/libexec/#{pkg_name}/bin/pre-deinstall"
      }
    }
    |> with_deps(pkg_deps())
    |> with_user(freebsd_config(:user))
  end

  def pkg_name, do: Mix.Project.config() |> Keyword.fetch!(:app)

  def pkg_version, do: Mix.Project.config() |> Keyword.fetch!(:version)

  def pkg_comment, do: Mix.Project.config() |> Keyword.fetch!(:description)

  def pkg_www, do: Mix.Project.config() |> Keyword.fetch!(:homepage_url)

  def pkg_description, do: freebsd_config() |> Map.fetch!(:description)

  def pkg_maintainer, do: freebsd_config() |> Map.fetch!(:maintainer)

  def pkg_prefix, do: "/usr/local"

  def pkg_deps, do: freebsd_config() |> Map.get(:deps)

  defp freebsd_config, do: Mix.Project.config() |> Keyword.fetch!(:freebsd)

  defp freebsd_config(key),
    do: Mix.Project.config() |> Keyword.fetch!(:freebsd) |> Map.get(key)

  defp with_deps(manifest, nil), do: manifest
  defp with_deps(manifest, deps), do: Map.put(manifest, :deps, deps)

  defp with_user(manifest, nil), do: manifest
  defp with_user(manifest, username), do: Map.put(manifest, :users, [username])
end
