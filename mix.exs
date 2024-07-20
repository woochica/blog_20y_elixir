defmodule Blog20y.MixProject do
  use Mix.Project

  def project do
    [
      app: :blog_20y,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  defp aliases() do
    [
      "site.build": ["build", "tailwind default --minify"]
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
      {:nimble_publisher, "~> 1.1.0"},
      {:phoenix_live_view, "~> 0.18.2"},
      {:yaml_front_matter, "~> 1.0"},
      {:xml_builder, "~> 2.3.0"},
      {:html_entities, "~> 0.5"},
      {:tailwind, "~> 0.1.8"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
