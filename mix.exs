defmodule Geocalc.Mixfile do
  use Mix.Project

  def project do
    [
      app: :geocalc,
      name: "Geocalc",
      version: "0.7.1",
      elixir: "~> 1.0",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      source_url: "https://github.com/yltsrc/geocalc",
      description: description(),
      test_coverage: [tool: Coverex.Task],
      package: package(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:benchfella, "~> 0.3.5", only: :bench},
      {:coverex, "~> 1.5.0", only: :test},
      {:credo, "~> 0.10.2", only: [:dev, :test]},
      {:ex_doc, "~> 0.19.1", only: :dev},
      {:mix_test_watch, "~> 0.9.0", only: :dev}
    ]
  end

  defp description do
    """
    Calculate distance, bearing and more between latitude/longitude points.
    """
  end

  defp package do
    [
      files: ["lib", "priv", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Yura Tolstik"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/yltsrc/geocalc",
        "Docs" => "http://hexdocs.pm/geocalc/"
      }
    ]
  end
end
