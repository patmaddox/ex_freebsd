defmodule FreeBSD do
  @moduledoc """
  Documentation for `FreeBSD`.
  """

  def pkg_name, do: Mix.Project.config() |> Keyword.fetch!(:app)

  def pkg_version, do: Mix.Project.config() |> Keyword.fetch!(:version)

  def pkg_comment, do: Mix.Project.config() |> Keyword.fetch!(:description)

  def pkg_www, do: Mix.Project.config() |> Keyword.fetch!(:homepage_url)

  def pkg_maintainer, do: freebsd_config() |> Keyword.fetch!(:maintainer)

  def pkg_prefix, do: freebsd_config() |> Keyword.fetch!(:pkg_prefix)

  defp freebsd_config, do: Mix.Project.config() |> Keyword.fetch!(:freebsd)
end
