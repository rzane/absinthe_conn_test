defmodule Absinthe.ConnTest.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/rzane/absinthe_conn_test"

  def project do
    [
      app: :absinthe_conn_test,
      version: @version,
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:absinthe, "~> 1.5"},
      {:plug, "~> 1.0"},
      {:phoenix, "~> 1.0"},
      {:jason, ">= 0.0.0", only: :test},
      {:absinthe_plug, ">= 0.0.0", only: :test},
      {:ex_doc, "~> 0.23", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      description: "Utilities for testing GraphQL APIs",
      maintainers: ["Ray Zane"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url,
      extras: ["README.md"]
    ]
  end
end
