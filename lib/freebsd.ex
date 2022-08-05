defmodule FreeBSD do
  @moduledoc """
  `mix.exs` config values that will be assigned to the EEX templates when
  building the package.
  """

  def pkg_manifest do
    %{
      name: pkg_name(),
      version: pkg_version(),
      origin: "devel/#{pkg_name()}",
      comment: pkg_comment(),
      www: pkg_www(),
      maintainer: pkg_maintainer(),
      prefix: pkg_prefix(),
      desc: pkg_description()
    }
    |> with_deps(pkg_deps())
    |> with_user(freebsd_config(:user))
    |> with_scripts(freebsd_config(:user))
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

  def with_scripts(manifest, username) do
    manifest
    |> Map.put(:scripts, %{
      "pre-install" =>
        Enum.join(
          [
            create_user_script(username),
            create_config_dir_script()
          ],
          "\n"
        ),
      "post-deinstall" =>
        Enum.join(
          [
            remove_user_script(username)
          ],
          "\n"
        )
    })
  end

  defp create_user_script(nil), do: ""

  defp create_user_script(username) do
    pkg_name = pkg_name()

    """
    if [ -n "${PKG_ROOTDIR}" ] && [ "${PKG_ROOTDIR}" != "/" ]; then
      PW="/usr/sbin/pw -R ${PKG_ROOTDIR}"
    else
      PW=/usr/sbin/pw
    fi
    echo "===> Creating groups."
    if ! ${PW} groupshow #{username} >/dev/null 2>&1; then
      echo "Creating group '#{username}'."
      ${PW} groupadd #{username}
    else
      echo "Using existing group '#{username}'."
    fi
    echo "===> Creating user"
    if ! ${PW} usershow #{username} >/dev/null 2>&1; then
      echo "Creating user '#{username}'."
      ${PW} useradd #{username} -g #{username} -c "#{pkg_name} user" -d /usr/local/libexec/#{pkg_name} -s /bin/sh
    else
      echo "Using existing user '#{username}'."
    fi
    """
  end

  defp create_config_dir_script() do
    pkg_name = pkg_name()
    config_dir = "/usr/local/etc/#{pkg_name}.d"
    config_file = "/usr/local/etc/#{pkg_name}.d/#{pkg_name}.env"

    """
    echo "===> Creating config"
    if [ ! -d "#{config_dir}" ]
    then
      mkdir -p #{config_dir}
      chmod 0755 #{config_dir}
    else
      echo "Using existing config directory #{config_dir}"
    fi

    if [ ! -f "#{config_file}" ]
    then
      touch "#{config_file}"
    else
      echo "Using existing config file '#{config_file}'"
    fi
    """
  end

  defp remove_user_script(nil), do: ""

  defp remove_user_script(username) do
    """
    if [ -n "${PKG_ROOTDIR}" ] && [ "${PKG_ROOTDIR}" != "/" ]; then
      PW="/usr/sbin/pw -R ${PKG_ROOTDIR}"
    else
      PW=/usr/sbin/pw
    fi
    if ${PW} usershow #{username} >/dev/null 2>&1; then
      echo "==> pkg user '#{username}' should be manually removed."
      echo "  ${PW} userdel #{username}"
    fi
    """
  end
end
