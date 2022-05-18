defmodule FreeBSD.MixProject do
  use Mix.Project

  def project do
    [
      app: :freebsd,
      version: "0.2.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: description(),
      source_url: "https://github.com/patmaddox/ex_freebsd",
      homepage_url: "https://github.com/patmaddox/ex_freebsd",
      freebsd: freebsd(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  def application do
    [
      extra_applications: [:logger, :eex]
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp files do
    [
      "README.md",
      "lib/**/*.ex",
      "priv/**/**.eex"
    ]
  end

  defp package do
    [
      licenses: ["BSD-2-Clause-FreeBSD"],
      links: %{"GitHub" => "https://github.com/patmaddox/ex_freebsd"},
      files: files()
    ]
  end

  defp description do
    "mix tasks for converting Elixir projects to FreeBSD packages."
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp freebsd do
    [
      maintainer: "pat@patmaddox.com",
      pkg_prefix: "/usr/local"
    ]
  end
end
