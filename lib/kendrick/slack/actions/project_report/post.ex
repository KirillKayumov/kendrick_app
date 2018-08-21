defmodule Kendrick.Slack.Actions.ProjectReport.Post do
  use GenServer

  import OK, only: [~>>: 2]

  import Kendrick.Slack.ProjectReport.Shared, only: [title: 0]

  import Kendrick.Slack.Shared,
    only: [find_workspace: 1, find_project: 1, find_channel: 1, find_user: 1, decode_callback_id: 1]

  alias Kendrick.Slack

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def slack(params) do
    GenServer.cast(__MODULE__, {:call, :slack, params})
  end

  def basecamp(params) do
    GenServer.cast(__MODULE__, {:call, :basecamp, params})
  end

  def init(args) do
    {:ok, args}
  end

  def handle_cast({:call, post_type, params}, state) do
    %{params: params}
    |> decode_callback_id()
    ~>> find_workspace()
    ~>> find_project()
    ~>> find_user()
    ~>> find_channel()
    ~>> post(post_type)

    {:noreply, state}
  end

  defp post(%{project: project, user: user, channel: channel, workspace: workspace}, :slack) do
    Slack.Client.files_upload(%{
      token: workspace.slack_token,
      channel: channel,
      text: Slack.ProjectReport.SlackPost.build(project, user),
      title: title()
    })
  end

  defp post(%{project: project, user: user, channel: channel, workspace: workspace}, :basecamp) do
    Slack.Client.files_upload(%{
      token: workspace.slack_token,
      channel: channel,
      text: Slack.ProjectReport.BasecampPost.build(project, user),
      title: title()
    })
  end
end
