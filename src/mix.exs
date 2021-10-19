defmodule Lobotomist.MixProject do
  use Mix.Project

  def project do
    [
      app: :lobotomist,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Lobotomist.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nostrum, "~> 0.4.6"},
      {:finch, "~> 0.9"},
      {:jason, "~> 1.2"}
    ]
  end
end
