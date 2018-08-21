defmodule Kendrick.Slack.Actions.ProjectReport.Show do
  use GenServer

  import OK, only: [~>>: 2]
  import Kendrick.Slack.Shared, only: [find_workspace: 1, find_user: 1]

  alias Kendrick.{
    Projects,
    Slack
  }

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def call(params) do
    GenServer.cast(__MODULE__, {:call, params})
  end

  def init(args) do
    {:ok, args}
  end

  def handle_cast({:call, params}, state) do
    %{params: params}
    |> find_workspace()
    ~>> find_user()
    ~>> find_project()
    ~>> post_report()

    {:noreply, state}
  end

  defp find_project(%{user: user} = data) do
    project = Projects.for_user(user)

    {:ok, Map.put(data, :project, project)}
  end

  defp post_report(%{project: project, user: user, workspace: workspace}) do
    attachments = Slack.ProjectReport.build(project)

    Slack.Client.post_message(attachments, user.slack_channel, workspace.slack_token)
  end
end
