defmodule Absinthe.ConnTest.MixProject do
  use Mix.Project

  def project do
    [
      app: :absinthe_conn_test,
      version: "0.1.0",
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:absinthe, ">= 0.0.0"},
      {:plug, ">= 0.0.0"},
      {:phoenix, ">= 0.0.0"},
      {:jason, ">= 0.0.0", only: :test},
      {:absinthe_plug, ">= 0.0.0", only: :test}
    ]
  end
end
