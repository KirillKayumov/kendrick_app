# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :kendrick,
  ecto_repos: [Kendrick.Repo]

# Configures the endpoint
config :kendrick, KendrickWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "24IYb4xfsfgE/prIR3ypw+ojW8/milyubTJQtYmjJBK5ASjPAtAOOW8Cq3GujGHw",
  render_errors: [view: KendrickWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Kendrick.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
