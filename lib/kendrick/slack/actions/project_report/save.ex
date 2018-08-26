defmodule Kendrick.Slack.Actions.ProjectReport.Save do
  use GenServer

  import OK, only: [~>>: 2]

  import Kendrick.Slack.Shared,
    only: [find_workspace: 1, find_project: 1, find_channel: 1, decode_callback_id: 1]

  alias Kendrick.{
    Project,
    Repo,
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
    |> decode_callback_id()
    ~>> find_workspace()
    ~>> find_project()
    ~>> find_channel()
    ~>> save_timestamp()
    ~>> update_message()

    {:noreply, state}
  end

  defp save_timestamp(%{project: project} = data) do
    project =
      project
      |> Project.changeset(%{report_saved_at: DateTime.utc_now()})
      |> Repo.update!()

    {:ok, Map.put(data, :project, project)}
  end

  defp update_message(%{project: project, channel: channel, workspace: workspace, params: params}) do
    attachments = [Slack.ProjectReport.SaveMessage.build(project)]

    Slack.Client.chat_update(%{
      attachments: attachments,
      channel: channel,
      token: workspace.slack_token,
      ts: params["original_message"]["ts"]
    })
  end
end
