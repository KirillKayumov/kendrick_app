defmodule Kendrick.Slack.Actions.Tasks.More do
  use GenServer

  import OK, only: [~>>: 2]
  import Kendrick.Slack.Shared, only: [find_workspace: 1, find_user: 1, decode_callback_id: 1]

  alias Kendrick.Slack

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
    ~>> decode_callback_id()
    ~>> update_report()

    {:noreply, state}
  end

  defp update_report(%{params: params, workspace: workspace, user: user, callback_id: callback_id}) do
    Slack.Client.respond(%{
      attachments: Slack.Report.build(user, %{more_actions: callback_id["id"]}),
      token: workspace.slack_token,
      url: params["response_url"]
    })
  end
end
