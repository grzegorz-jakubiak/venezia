defmodule Venezia.MixProject do
  use Mix.Project

  def project do
    [
      app: :venezia,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Venezia.Application, []}
    ]
  end

  defp deps do
    [
      {:tesla, "~> 1.4"},
      {:hackney, "~> 1.17"},
      {:floki, "~> 0.31.0"},
      {:poolboy, "~> 1.5.2"}
    ]
  end
end
