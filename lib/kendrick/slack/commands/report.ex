defmodule Kendrick.Slack.Commands.Report do
  use GenServer

  alias Kendrick.{
    Repo,
    Slack,
    User,
    Users,
    Workspace,
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
    user = Users.get_by(slack_id: params["user_id"])
    workspace = Workspaces.get_by(team_id: params["team_id"])

    Slack.Client.post_message("lol", user.slack_channel, workspace.slack_token)

    {:noreply, state}
  end
end
