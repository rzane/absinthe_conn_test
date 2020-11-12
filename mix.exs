defmodule Absinthe.ConnTest.MixProject do
  use Mix.Project

  def project do
    [
      app: :absinthe_conn_test,
      version: "0.1.0",
      elixir: "~> 1.10",
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

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug, ">= 0.0.0"},
      {:phoenix, ">= 0.0.0"},
      {:jason, ">= 0.0.0", only: :test}
    ]
  end
end
