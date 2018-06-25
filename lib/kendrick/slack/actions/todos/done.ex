defmodule Kendrick.Slack.Actions.Todos.Done do
  use GenServer

  import OK, only: [~>>: 2]
  import Kendrick.Slack.Shared, only: [find_workspace: 1, find_user: 1]

  alias Kendrick.{
    Repo,
    Slack,
    Todo,
    Todos
  }

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
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
    ~>> make_done()
    ~>> update_report()

    {:noreply, state}
  end

  defp find_todo(%{params: params} = data) do
    todo = Todos.get(params["callback_id"])

    {:ok, Map.put(data, :todo, todo)}
  end

  defp make_done(%{todo: todo} = data) do
    todo
    |> Todo.changeset(%{done: true})
    |> Repo.update!()

    {:ok, data}
  end

  defp update_report(%{params: params, user: user, workspace: workspace}) do
    Slack.Client.respond(%{
      attachments: Slack.Report.build(user),
      token: workspace.slack_token,
      url: params["response_url"]
    })
  end
end
