defmodule Kendrick.Application do
  use Application

  alias Kendrick.Repo
  alias KendrickWeb.Endpoint
  alias Kendrick.Slack.{
    Actions,
    Commands,
    NoUserNotifier
  }

  def start(_type, _args) do
    children = [
      Actions.ProjectReport.Post,
      Actions.ProjectReport.Save,
      Actions.ProjectReport.Show,
      Actions.Tasks.Create,
      Actions.Tasks.Delete,
      Actions.Tasks.Disable,
      Actions.Tasks.More,
      Actions.Tasks.ShowEditForm,
      Actions.Tasks.ShowNewForm,
      Actions.Tasks.Update,
      Actions.Tasks.UpdateStatus,
      Actions.Todos.Delete,
      Actions.Todos.Done,
      Actions.Users.UpdateAbsence,
      Commands.Report,
      Commands.Start,
      Commands.Todo,
      Endpoint,
      NoUserNotifier,
      Repo
    ]

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
