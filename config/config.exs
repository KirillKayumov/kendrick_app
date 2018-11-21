use Mix.Config

config :phoenix, :json_library, Jason

config :kendrick,
  ecto_repos: [Kendrick.Repo]

config :kendrick, KendrickWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "24IYb4xfsfgE/prIR3ypw+ojW8/milyubTJQtYmjJBK5ASjPAtAOOW8Cq3GujGHw",
  render_errors: [view: KendrickWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Kendrick.PubSub, adapter: Phoenix.PubSub.PG2]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :kendrick, Kendrick.Guardian,
  issuer: "kendrick",
  secret_key: System.get_env("GUARDIAN_SECRET_KEY")

config :ueberauth, Ueberauth,
  providers: [
    slack: {Kendrick.Ueberauth.Strategy.Slack, []}
  ]

config :ueberauth, Kendrick.Ueberauth.Strategy.Slack.OAuth,
  client_id: System.get_env("SLACK_CLIENT_ID"),
  client_secret: System.get_env("SLACK_CLIENT_SECRET")

config :kendrick, Kendrick.Jira.API,
  username: System.get_env("JIRA_USERNAME"),
  password: System.get_env("JIRA_PASSWORD"),
  host: System.get_env("JIRA_HOST")

config :quantum, timezone: "Europe/Moscow"

config :kendrick, date_time: DateTime

import_config "#{Mix.env()}.exs"
