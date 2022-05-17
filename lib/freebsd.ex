defmodule FreeBSD do
  @moduledoc """
  Documentation for `FreeBSD`.
  """

  def config do
    %{
      port_name: port_name(),
      port_version: port_version(),
      port_categories: port_categories(),
      port_maintainer: port_maintainer(),
      port_comment: port_comment(),
      port_www: port_www(),
      github_project: github_project(),
      github_account: github_account(),
      github_tag: github_tag(),
      pkg_prefix: pkg_prefix()
    }
  end

  def port_name do
    {:ok, app} = Mix.Project.config() |> Keyword.fetch(:app)
    app
  end

  def port_version do
    {:ok, version} = Mix.Project.config() |> Keyword.fetch(:version)
    version
  end

  def port_comment do
    {:ok, comment} = Mix.Project.config() |> Keyword.fetch(:description)
    comment
  end

  def freebsd_config do
    {:ok, freebsd} = Mix.Project.config() |> Keyword.fetch(:freebsd)
    freebsd
  end

  def port_categories do
    {:ok, categories} = freebsd_config() |> Keyword.fetch(:categories)
    categories
  end

  def port_maintainer do
    {:ok, maintainer} = freebsd_config() |> Keyword.fetch(:maintainer)
    maintainer
  end

  def port_www do
    {:ok, www} = freebsd_config() |> Keyword.fetch(:www)
    www
  end

  def github_account do
    {:ok, github_account} = freebsd_config() |> Keyword.fetch(:github_account)
    github_account
  end

  def github_project do
    {:ok, github_project} = freebsd_config() |> Keyword.fetch(:github_project)
    github_project
  end

  def github_tag do
    {:ok, github_tag} = freebsd_config() |> Keyword.fetch(:github_tag)
    github_tag
  end

  def pkg_prefix do
    {:ok, pkg_prefix} = freebsd_config() |> Keyword.fetch(:pkg_prefix)
    pkg_prefix
  end
end
