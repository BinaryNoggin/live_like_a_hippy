defmodule Hoarder.Mixfile do
  use Mix.Project

  def project do
    [app: :hoarder,
     version: "0.1.0",
     elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger],
     mod: {Hoarder.Application, []}]
  end

  defp deps do
    [
      {:ecto, "~> 2.0"},
      {:postgrex, "~> 0.13"},
      {:comeonin, "~> 2.0"},
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

 defp aliases do
   ["test": ["ecto.create --quiet", "ecto.migrate", "test"]]
 end
end
