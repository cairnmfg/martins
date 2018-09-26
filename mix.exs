defmodule Martins.MixProject do
  use Mix.Project

  def project() do
    [
      app: :martins,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  def application() do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps() do
    [
      # Small, fast, modular HTTP server
      {:cowboy, "~> 2.4"},
      # Authentication with JWT
      {:guardian, "~> 1.1"},
      # JSON parser and generator in pure Elixir
      {:jason, "~> 1.1"},
      # Automatically run your Elixir project's tests each time you save a file
      {:mix_test_watch, "~> 0.8", only: :dev, runtime: false},
      {:plug, "~> 1.6"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
