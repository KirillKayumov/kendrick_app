defmodule Kendrick.Slack.NoUserNotifier do
  use GenServer

  import OK, only: [~>>: 2]
  import Kendrick.Slack.Shared, only: [find_workspace: 1, find_user_slack_id: 1, find_channel: 1]

  alias Kendrick.Slack

  @name :slack_no_user_notifier_worker

  def start_link do
    GenServer.start_link(__MODULE__, [], name: @name)
  end

  def call(params) do
    GenServer.cast(@name, {:call, params})
  end

  def init(args) do
    {:ok, args}
  end

  def handle_cast({:call, params}, state) do
    %{params: params}
    |> find_workspace()
    ~>> find_user_slack_id()
    ~>> find_channel()
    ~>> post_message()

    {:noreply, state}
  end

  defp post_message(%{channel: channel, user_slack_id: user_slack_id, workspace: workspace}) do
    Slack.Client.chat_post_ephemeral(
      ":warning: Please type `/start` to start using the app.",
      channel,
      user_slack_id,
      workspace.slack_token
    )
  end
end
