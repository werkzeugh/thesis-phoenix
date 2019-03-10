use Mix.Config

config :thesis, store: Thesis.EctoStore
config :thesis, Thesis.EctoStore, repo: MyApp.Repo
config :thesis, env: Mix.env

import_config "#{Mix.env}.exs"
