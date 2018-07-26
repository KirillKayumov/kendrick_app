defmodule Kendrick.Mixfile do
  use Mix.Project

  def project do
    [
      app: :kendrick,
      version: "0.0.1",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
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
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:cowboy, "~> 1.0"},
      {:gettext, "~> 0.11"},
      {:guardian, "~> 1.0"},
      {:httpoison, "~> 1.1"},
      {:jira, "~> 0.0.8"},
      {:oauth2, "~> 0.9.2"},
      {:phoenix_active_link, "~> 0.2.1"},
      {:phoenix_ecto, "~> 3.2"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix, "~> 1.3.2"},
      {:postgrex, ">= 0.0.0"},
      {:ueberauth, "~> 0.5.0"},
      {:ok, "~> 1.11"},
      {:timex, "~> 3.3"},
      {:ex_cldr_numbers, "~> 1.5"}
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
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
