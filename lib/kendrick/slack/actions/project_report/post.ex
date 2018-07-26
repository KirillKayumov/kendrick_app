defmodule Kendrick.Slack.Actions.ProjectReport.Post do
  use GenServer

  import OK, only: [~>>: 2]
  import Kendrick.Slack.Shared, only: [find_workspace: 1, find_project: 1, find_channel: 1, decode_callback_id: 1]

  alias Kendrick.Slack

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
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
    ~>> post()

    {:noreply, state}
  end

  defp post(%{project: project, channel: channel, workspace: workspace}) do
    Slack.Client.files_upload(%{
      token: workspace.slack_token,
      channel: channel,
      text: Slack.ProjectReport.Post.build(project),
      title: title()
    })
  end

  defp title do
    today = Date.utc_today()
    month = Timex.format!(today, "%B", :strftime)
    day = Cldr.Number.to_string!(today.day, format: :ordinal)

    "DAILY REPORT: #{month} #{day}"
  end
end
