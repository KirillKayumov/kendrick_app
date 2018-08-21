defmodule Kendrick.Slack.Commands.Report do
  use GenServer

  import OK, only: [~>>: 2]
  import Kendrick.Slack.Shared, only: [find_workspace: 1, find_user: 1]

  alias Kendrick.{
    Repo,
    Slack,
    User
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
    ~>> find_user()
    ~>> post_report()
    ~>> save_report_ts()

    {:noreply, state}
  end

  defp post_report(%{user: user, workspace: workspace} = data) do
    attachments = Slack.Report.build(user)
    response = Slack.Client.post_message(attachments, user.slack_channel, workspace.slack_token)

    {:ok, Map.put(data, :report_ts, response["ts"])}
  end

  defp save_report_ts(%{user: user, report_ts: report_ts}) do
    user
    |> User.changeset(%{report_ts: report_ts})
    |> Repo.update!()
  end
end
