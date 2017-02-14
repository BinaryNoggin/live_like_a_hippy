use Mix.Config

config :logger, level: :warn

config :hoarder, Hoarder.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "hoarder_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
