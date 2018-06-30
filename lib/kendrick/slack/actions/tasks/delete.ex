defmodule Kendrick.Slack.Actions.Tasks.Delete do
  use GenServer

  import OK, only: [~>>: 2]
  import Kendrick.Slack.Shared, only: [find_user: 1, find_workspace: 1]
  import Kendrick.Slack.Actions.Tasks.Shared, only: [find_task: 1]

  alias Kendrick.{
    Repo,
    Slack
  }

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def call(params) do
    GenServer.call(__MODULE__, {:call, params})
  end

  def init(args) do
    {:ok, args}
  end

  def handle_call({:call, params}, _from, state) do
    result =
      %{params: params}
      |> find_workspace()
      ~>> find_user()
      ~>> find_task()
      ~>> delete_task()
      ~>> update_report()

    {:reply, result, state}
  end

  defp delete_task(%{task: task} = data) do
    Repo.delete!(task)

    {:ok, data}
  end

  defp update_report(%{params: params, workspace: workspace, user: user}) do
    Slack.Client.respond(%{
      attachments: Slack.Report.build(user),
      token: workspace.slack_token,
      url: params["response_url"]
    })
  end
end
