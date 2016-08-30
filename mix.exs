defmodule RallyApi.Mixfile do
  use Mix.Project

  @description """
  A toolkit wrapping Rally's REST webservice for Elixir
  """

  def project do
    [app: :rally_api,
     version: "0.1.0",
     elixir: "~> 1.3",
     name: "RallyRestToolkitForElixir",
     description: @description,
     package: package(),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     source_url: "https://github.com/jcartwright/rally_api" ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :httpoison]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [ {:httpoison, "~> 0.9.0"},
      {:poison, "~> 2.0"} ]
  end

  defp package do
    [ maintainers: ["Jason Cartwright"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/jcartwright/rally_api"} ]
  end
end
