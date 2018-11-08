defmodule Kendrick.Slack.Actions.ProjectReport.Close do
  use GenServer

  import OK, only: [~>>: 2]
  import Kendrick.Slack.Shared, only: [find_workspace: 1, find_channel: 1]

  alias Kendrick.{
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
    ~>> find_channel()
    ~>> delete_message()

    {:noreply, state}
  end

  defp delete_message(%{workspace: workspace, channel: channel, params: params}) do
    Slack.Client.chat_delete(%{
      channel: channel,
      token: workspace.slack_token,
      ts: params["original_message"]["ts"]
    })
  end
end
