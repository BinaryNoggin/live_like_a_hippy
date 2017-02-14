use Mix.Config

config :hoarder, Hoarder.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "hoarder",
  hostname: "localhost"

