defmodule Thesis.Mixfile do
  use Mix.Project
  @version "0.3.4" # REMEMBER TO UPDATE package.json and both READMEs!

  def project do
    [
      app: :thesis,
      version: @version,
      elixir: ">= 1.4.0",
      description: description(),
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      package: package(),
      dialyzer: [plt_add_deps: :transitive]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:phoenix, ">= 1.2.0"},
      {:phoenix_html, ">= 2.0.0"},
      {:ecto, ">= 2.0.0"},
      {:plug, ">= 1.0.0"},
      {:poison, ">= 1.0.0"},
      {:httpoison, ">= 0.11.0"},
      {:html_sanitize_ex, ">= 1.3.0"},
      {:lz_string, "~> 0.0.7"},
      {:ex_doc, ">= 0.12.0", only: [:dev]},
      {:earmark, ">= 0.2.0", only: [:dev]},
      {:dialyxir, ">= 0.3.5", only: [:dev]},
      {:credo, ">= 0.7.4", only: [:dev]},
    ]
  end

  defp description do
    """
    Thesis is a lightweight bolt-on content editing system
    for Phoenix websites.
    """
  end

  defp package do
    [
      files: ["lib", "priv", "mix.exs", "README*", "LICENSE*", "package.json"],
      licenses: ["MIT"],
      maintainers: ["Jamon Holmgren", "Yulian Glukhenko", "Ken Miller", "Daniel Berkompas"],
      links: %{
        "GitHub" => "https://github.com/infinitered/thesis-phoenix",
        "Docs" => "https://hexdocs.pm/thesis/#{@version}/api-reference.html",
        # "Tutorials" => "https://infinite.red/thesis/" # TODO
      }
    ]
  end
end
