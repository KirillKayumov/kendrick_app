defmodule Kendrick.Slack.NoUserNotifier do
  use GenServer

  import OK, only: [~>>: 2]
  import Kendrick.Slack.Shared, only: [find_workspace: 1]

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
    ~>> post_message()

    {:noreply, state}
  end

  defp post_message(data) do
    %{
      params: %{
        "channel_id" => channel,
        "user_id" => user
      },
      workspace: workspace
    } = data

    Slack.Client.chat_post_ephemeral(
      ":warning: Please type `/start` to start using the app.",
      channel,
      user,
      workspace.slack_token
    )
  end
end
