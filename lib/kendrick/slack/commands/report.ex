defmodule Kendrick.Slack.Commands.Report do
  use GenServer

  alias Kendrick.{
    Slack,
    Users,
    Workspaces
  }

  @name :slack_commands_report_worker

  def start_link do
    GenServer.start_link(__MODULE__, [], name: @name)
  end

  def call(params) do
    GenServer.cast(@name, {:do_call, params})
  end

  def init(args) do
    {:ok, args}
  end

  def handle_cast({:do_call, params}, state) do
    %{params: params}
    |> get_user()
    |> get_workspace()
    |> build_report()
    |> post_message()

    {:noreply, state}
  end

  defp get_user(%{params: params} = data) do
    user = Users.get_by(slack_id: params["user_id"])

    Map.put(data, :user, user)
  end

  defp get_workspace(%{params: params} = data) do
    workspace = Workspaces.get_by(team_id: params["team_id"])

    Map.put(data, :workspace, workspace)
  end

  defp build_report(%{user: user} = data) do
    attachments = Slack.Report.build(user)

    Map.put(data, :attachments, attachments)
  end

  defp post_message(%{attachments: attachments, user: user, workspace: workspace}) do
    Slack.Client.post_message(attachments, user.slack_channel, workspace.slack_token)
  end
end
