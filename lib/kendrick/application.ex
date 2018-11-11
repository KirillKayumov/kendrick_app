defmodule Kendrick.Application do
  use Application

  alias KendrickWeb.Endpoint

  alias Kendrick.{
    Repo,
    Scheduler,
    Slack,
    Tasks
  }

  def start(_type, _args) do
    start_application(%{
      repo_only: System.get_env("REPO_ONLY")
    })
  end

  defp start_application(%{repo_only: repo_only}) when not is_nil(repo_only) do
    start_supervisor([Repo])
  end

  defp start_application(_config) do
    children = [
      Endpoint,
      Repo,
      Scheduler,
      Slack.Actions.ProjectReport.Close,
      Slack.Actions.ProjectReport.Post,
      Slack.Actions.ProjectReport.Save,
      Slack.Actions.ProjectReport.Show,
      Slack.Actions.Tasks.Create,
      Slack.Actions.Tasks.Delete,
      Slack.Actions.Tasks.Disable,
      Slack.Actions.Tasks.More,
      Slack.Actions.Tasks.ShowEditForm,
      Slack.Actions.Tasks.ShowNewForm,
      Slack.Actions.Tasks.Update,
      Slack.Actions.Tasks.UpdateStatus,
      Slack.Actions.Todos.Delete,
      Slack.Actions.Todos.Done,
      Slack.Actions.Users.UpdateAbsence,
      Slack.Commands.Report,
      Slack.Commands.Start,
      Slack.Commands.Todo,
      Slack.Events.LinkShared,
      Slack.Events.ReactionAdded,
      Slack.NoUserNotifier,
      Slack.Report.Remind.Supervisor,
      Slack.ReviewReminders.Worker,
      Tasks.CleanUp.Supervisor,
      Tasks.Sync.Supervisor
    ]

    start_supervisor(children)
  end

  defp start_supervisor(children) do
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
