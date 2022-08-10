defmodule Basic.MixProject do
  use Mix.Project

  def project do
    [
      app: :freebsd_basic,
      deps: deps(),
      description: "Basic freebsd package",
      elixir: "~> 1.13",
      freebsd: freebsd(),
      homepage_url: "https://github.com/patmaddox/ex_freebsd",
      releases: releases(),
      start_permanent: Mix.env() == :prod,
      version: "0.1.0"
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Basic.Application, []}
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
      description: "Basic freebsd package",
      deps: %{
        bash: %{version: "5.1", origin: "shells/bash"}
      }
    }
  end

  def releases do
    [
      freebsd_basic: [
        include_executables_for: [:unix]
      ]
    ]
  end
end
