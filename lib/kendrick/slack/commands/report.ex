defmodule Kendrick.Slack.Commands.Report do
  use GenServer

  import OK, only: [~>>: 2]
  import Kendrick.Slack.Shared, only: [find_workspace: 1, find_user: 1]

  alias Kendrick.Slack

  @name :slack_commands_report_worker

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
    ~>> find_user()
    ~>> build_report()
    |> post_report()

    {:noreply, state}
  end

  defp build_report(%{user: user} = data) do
    attachments = Slack.Report.build(user)

    Map.put(data, :attachments, attachments)
  end

  defp post_report(%{attachments: attachments, user: user, workspace: workspace}) do
    Slack.Client.post_message(attachments, user.slack_channel, workspace.slack_token)
  end
end
