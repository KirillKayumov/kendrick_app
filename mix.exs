defmodule Kendrick.Mixfile do
  use Mix.Project

  def project do
    [
      app: :kendrick,
      version: "0.0.1",
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      preferred_cli_env: [espec: :test]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Kendrick.Application, []},
      extra_applications: [:logger, :runtime_tools, :ueberauth, :timex, :ex_cldr]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "spec/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:ecto_sql, "~> 3.0"},
      {:espec, "~> 1.6", only: :test},
      {:espec_phoenix, "~> 0.6", only: :test},
      {:ex_cldr_numbers, "~> 1.5"},
      {:gettext, "~> 0.11"},
      {:guardian, "~> 1.0"},
      {:httpoison, "~> 1.1"},
      {:jason, "~> 1.0"},
      {:mox, "~> 0.4.0", only: :test},
      {:oauth2, "~> 0.9.2"},
      {:ok, "~> 1.11"},
      {:phoenix, "~> 1.4.0"},
      {:phoenix_active_link, "~> 0.2.1"},
      {:phoenix_ecto, "~> 4.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:phoenix_pubsub, "~> 1.0"},
      {:plug, "~> 1.7"},
      {:plug_cowboy, "~> 2.0"},
      {:postgrex, ">= 0.0.0"},
      {:quantum, "~> 2.3"},
      {:timex, "~> 3.3"},
      {:ueberauth, "~> 0.5.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "espec"]
    ]
  end
end
