defmodule Kendrick.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Kendrick.Repo, []),
      # Start the endpoint when the application starts
      supervisor(KendrickWeb.Endpoint, []),
      worker(Kendrick.Slack.Commands.Start, []),
      worker(Kendrick.Slack.Commands.Report, []),
      worker(Kendrick.Slack.Commands.Todo, []),
      worker(Kendrick.Slack.Actions.Tasks.ShowNewForm, []),
      worker(Kendrick.Slack.Actions.Tasks.Create, []),
      worker(Kendrick.Slack.Actions.Tasks.UpdateStatus, []),
      worker(Kendrick.Slack.Actions.Tasks.More, []),
      worker(Kendrick.Slack.Actions.Tasks.ShowEditForm, []),
      worker(Kendrick.Slack.Actions.Tasks.Update, []),
      worker(Kendrick.Slack.Actions.Tasks.Disable, []),
      worker(Kendrick.Slack.Actions.Tasks.Delete, []),
      worker(Kendrick.Slack.Actions.Todos.Done, []),
      worker(Kendrick.Slack.Actions.Todos.Delete, []),
      worker(Kendrick.Slack.Actions.ProjectReport.Show, []),
      worker(Kendrick.Slack.Actions.ProjectReport.Post, []),
      worker(Kendrick.Slack.Actions.Users.UpdateAbsence, []),
      worker(Kendrick.Slack.NoUserNotifier, [])
      # Start your own worker by calling: Kendrick.Worker.start_link(arg1, arg2, arg3)
      # worker(Kendrick.Worker, [arg1, arg2, arg3]),
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Kendrick.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    KendrickWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
