defmodule Geocalc.Mixfile do
  use Mix.Project

  @source_url "https://github.com/yltsrc/geocalc"
  @version "0.8.4"

  def project do
    [
      app: :geocalc,
      name: "Geocalc",
      version: @version,
      elixir: "~> 1.9",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: Coverex.Task],
      dialyzer: dialyzer(),
      package: package(),
      deps: deps(),
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:benchfella, "~> 0.3.5", only: :bench},
      {:coverex, "~> 1.5.0", only: :test},
      {:credo, "~> 1.6.0", only: [:dev, :test]},
      {:decimal, "~> 2.0"},
      {:dialyxir, "~> 1.2", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:mix_test_watch, "~> 1.1.0", only: :dev}
    ]
  end

  defp dialyzer() do
    [
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
    ]
  end

  defp package do
    [
      description: "Calculate distance, bearing and more between latitude/longitude points.",
      files: ["lib", "priv", "mix.exs", "README*", "CHANGELOG*", "LICENSE*"],
      maintainers: ["Yura Tolstik"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url
      }
    ]
  end

  defp docs do
    [
      extras: [
        "CHANGELOG.md",
        {:"LICENSE.md", [title: "License"]},
        "README.md"
      ],
      main: "readme",
      source_url: @source_url,
      source_ref: "#{@version}",
      formatters: ["html"]
    ]
  end
end
