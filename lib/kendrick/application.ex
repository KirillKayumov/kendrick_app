defmodule Kendrick.Application do
  use Application

  alias Kendrick.Slack.{
    Actions,
    Commands,
    NoUserNotifier
  }

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
      worker(Commands.Start, []),
      worker(Commands.Report, []),
      worker(Commands.Todo, []),
      worker(Actions.Tasks.ShowNewForm, []),
      worker(Actions.Tasks.Create, []),
      worker(Actions.Tasks.UpdateStatus, []),
      worker(Actions.Tasks.More, []),
      worker(Actions.Tasks.ShowEditForm, []),
      worker(Actions.Tasks.Update, []),
      worker(Actions.Tasks.Disable, []),
      worker(Actions.Tasks.Delete, []),
      worker(Actions.Todos.Done, []),
      worker(Actions.Todos.Delete, []),
      worker(Actions.ProjectReport.Show, []),
      worker(Actions.ProjectReport.Post, []),
      worker(Actions.ProjectReport.Save, []),
      worker(Actions.Users.UpdateAbsence, []),
      worker(NoUserNotifier, [])
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
