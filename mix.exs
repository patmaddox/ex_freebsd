defmodule FreeBSD.MixProject do
  use Mix.Project

  def project do
    [
      app: :freebsd,
      version: "0.1.0",
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
      "freebsd/*.eex"
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
      categories: ["patmaddox"],
      github_account: "patmaddox",
      github_project: "ex_freebsd",
      github_tag: "tbd",
      maintainer: "pat@patmaddox.com",
      www: "https://github.com/patmaddox/ex_freebsd"
    ]
  end
end
