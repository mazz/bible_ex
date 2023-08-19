defmodule BibleEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :bible_ex,
      version: "0.1.0",
      elixir: "~> 1.14",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      source_url: "https://github.com/mazz/bible_ex"
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
      {:ex_doc, "~> 0.29.2", only: :dev, runtime: false},
      {:earmark, "~> 1.4", only: :dev, runtime: false},
      {:dialyxir, "~> 0.3", only: [:dev], runtime: false}
    ]
  end

  defp description() do
    "An Elixir package that parses strings for Bible references."
  end

  defp package() do
    [
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*),
      maintainers: ["Michael Hanna"],
      licenses: ["BSD-2-Clause"],
      links: %{
        "GitHub" => "https://github.com/mazz/bible_ex",
        "Docs" => "https://hexdocs.pm/bible_ex/"
      }
    ]
  end
end
