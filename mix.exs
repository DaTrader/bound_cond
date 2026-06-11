defmodule BoundCond.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/DaTrader/bound_cond"

  def project do
    [
      app: :bound_cond,
      version: @version,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "BoundCond",
      description: description(),
      package: package(),
      source_url: @source_url,
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: []
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end

  defp description do
    "A cond variant whose clauses can thread interim variables through a :bind step."
  end

  defp package do
    [
      licenses: ["MIT"],
      maintainers: ["DaTrader"],
      links: %{
        "GitHub" => @source_url,
        "Changelog" => @source_url <> "/blob/main/CHANGELOG.md"
      }
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", "CHANGELOG.md", "LICENSE"],
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end
end
