defmodule Kendrick.Slack.Actions.Todos.Delete do
  use GenServer

  import OK, only: [~>>: 2]
  import Kendrick.Slack.Shared, only: [find_workspace: 1, find_user: 1]
  import Kendrick.Slack.Actions.Todos.Shared, only: [find_todo: 1, update_report: 1]

  alias Kendrick.Repo

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
    ~>> find_todo()
    ~>> delete()
    ~>> update_report()

    {:noreply, state}
  end

  defp delete(%{todo: todo} = data) do
    Repo.delete!(todo)

    {:ok, data}
  end
end
