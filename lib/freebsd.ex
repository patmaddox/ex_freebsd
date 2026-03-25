defmodule FreeBSD do
  @moduledoc """
  `mix.exs` config values that will be assigned to the EEX templates when
  building the package.
  """

  def pkg_manifest do
    pkg_name = pkg_name()
    user = pkg_user()

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
        "post-install" => post_install_script(),
        "pre-deinstall" => pre_deinstall_script()
      }
    }
    |> with_deps(pkg_deps())
    |> with_user(user)
  end

  def pkg_name, do: Mix.Project.config() |> Keyword.fetch!(:app) |> to_string()

  def pkg_version, do: Mix.Project.config() |> Keyword.fetch!(:version)

  def pkg_comment, do: Mix.Project.config() |> Keyword.fetch!(:description)

  def pkg_www, do: Mix.Project.config() |> Keyword.fetch!(:homepage_url)

  def pkg_description do
    freebsd_config()
    |> Map.fetch!(:description)
    |> case do
      d when is_function(d) -> d.()
      d -> d
    end
  end

  def pkg_maintainer, do: freebsd_config() |> Map.fetch!(:maintainer)

  def pkg_prefix, do: "/usr/local"

  def pkg_deps, do: freebsd_config() |> Map.get(:deps)

  def template_file(file),
    do: Application.app_dir(:freebsd, "priv/templates/freebsd.pkg/#{file}")

  def conf_dir, do: [pkg_prefix(), "etc", pkg_name() <> ".d"] |> Enum.join("/")

  def conf_dir_var, do: pkg_name() |> String.upcase()

  def env_file_name, do: "#{pkg_name()}.env"

  def pkg_user, do: freebsd_config() |> Map.get(:user)

  defp freebsd_config, do: Mix.Project.config() |> Keyword.fetch!(:freebsd)

  defp with_deps(manifest, nil), do: manifest
  defp with_deps(manifest, deps), do: Map.put(manifest, :deps, deps)

  defp with_user(manifest, nil), do: manifest
  defp with_user(manifest, username), do: Map.put(manifest, :users, [username])

  defp post_install_script do
    template_file("post_install.sh.eex")
    |> EEx.eval_file(
      assigns: %{
        pkg_name: pkg_name(),
        pkg_user: pkg_user(),
        config_dir: conf_dir(),
        env_file_name: env_file_name()
      }
    )
  end

  def pre_deinstall_script do
    template_file("pre_deinstall.sh.eex")
    |> EEx.eval_file(
      assigns: %{
        config_dir: conf_dir(),
        pkg_user: pkg_user(),
        var_dir: "/var/run/#{pkg_name()}"
      }
    )
  end

  def sample_file_contents do
    project_root = Mix.Project.config() |> Keyword.fetch!(:app_path) |> to_string()

    case freebsd_config() |> Map.get(:sample_env_file) do
      nil ->
        auto_detect_sample_file(project_root)

      path ->
        if File.exists?(path) do
          IO.puts("Using configured env sample at #{path}")
          "# Source: #{path}\n#{File.read!(path)}"
        else
          IO.warn("Configured sample_env_file '#{path}' not found, trying auto-detection")
          auto_detect_sample_file(project_root)
        end
    end
  end

  defp auto_detect_sample_file(project_root) do
    candidate_paths = [
      Path.join(project_root, "sample.env"),
      Path.join(project_root, ".env.sample"),
      Path.join(project_root, ".env")
    ]

    case Enum.find(candidate_paths, &File.exists?/1) do
      nil ->
        default_sample_contents()

      path ->
        IO.puts("Found env sample at #{path}, using it")
        "# Source: #{path}\n#{File.read!(path)}"
    end
  end

  defp default_sample_contents do
    """
    # Environment variables defined here will be available to your application.
    # RELEASE_COOKIE="generate with Base.url_encode64(:crypto.strong_rand_bytes(40))"
    # DATABASE_URL="ecto://username:password@host/database"
    """
  end
end
