# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :example_phx,
  ecto_repos: [ExamplePhx.Repo]

config :example_phx, env: Mix.env

# Configures the endpoint
config :example_phx, ExamplePhxWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "mOs3MKJVPN4vBI53teBwWNqhE13lBDY+XlQh2AXcJw0O1WzKXuHqTdFM6SmTB2nP",
  render_errors: [view: ExamplePhxWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ExamplePhx.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :thesis,
  store: Thesis.EctoStore,
  authorization: ExamplePhx.ThesisAuth,
  uploader: Thesis.RepoUploader

config :thesis, Thesis.EctoStore,
  repo: ExamplePhx.Repo

config :thesis, :dynamic_pages,
  view: ExamplePhxWeb.PageView,
  templates: ["index.html"],
  not_found_view: ExamplePhxWeb.ErrorView,
  not_found_template: "404.html"

config :thesis, :notifications,
  page_settings: ["The changes made here will affect your SEO", "Notification 2"],
  add_page: ["The page you are creating will only be visible on the staging site.", "Notification 3"],
  import_export_restore: &ExamplePhx.Notifications.random_notification/1

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
