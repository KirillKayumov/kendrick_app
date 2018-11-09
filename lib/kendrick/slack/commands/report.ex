defmodule Kendrick.Slack.Commands.Report do
  use GenServer

  import OK, only: [~>>: 2]
  import Kendrick.Slack.Shared, only: [find_workspace: 1, find_user: 1]

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
    ~>> post_report()

    {:noreply, state}
  end

  defp post_report(%{user: user, workspace: workspace}) do
    report = Slack.Report.build(user)

    Slack.Report.Post.call(%{
      report: report,
      user: user,
      workspace: workspace
    })
  end
end
