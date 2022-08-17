defmodule User.MixProject do
  use Mix.Project

  def project do
    [
      app: :freebsd_user,
      deps: deps(),
      description: "freebsd package with non-root user",
      elixir: "~> 1.13",
      freebsd: freebsd(),
      homepage_url: "https://github.com/patmaddox/ex_freebsd",
      start_permanent: Mix.env() == :prod,
      version: "0.1.0"
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {User.Application, []}
    ]
  end

  defp deps do
    [
      {:freebsd, path: "../../..", runtime: false}
    ]
  end

  defp freebsd do
    %{
      maintainer: "admin@example.com",
      description: fn -> "freebsd package with non-root user" end,
      user: "appuser"
    }
  end
end
