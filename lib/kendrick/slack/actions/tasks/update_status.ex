defmodule Kendrick.Slack.Actions.Tasks.UpdateStatus do
  use GenServer

  import OK, only: [~>>: 2]
  import Kendrick.Slack.Shared, only: [find_workspace: 1, find_user: 1]

  alias Kendrick.{
    Repo,
    Slack,
    Task,
    Tasks
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
    ~>> find_task()
    ~>> update_status()
    ~>> post_report()

    {:noreply, state}
  end

  defp find_task(%{params: params} = data) do
    task = Tasks.get(params["callback_id"])

    {:ok, Map.put(data, :task, task)}
  end

  defp update_status(%{params: params, task: task} = data) do
    %{
      "actions" => [
        %{
          "selected_options" => [%{"value" => status}]
        }
      ]
    } = params

    task
    |> Task.changeset(%{status: status})
    |> Repo.update!()

    {:ok, data}
  end

  defp post_report(%{params: params, workspace: workspace, user: user}) do
    attachments = Slack.Report.build(user)

    Slack.Client.respond(
      url: params["response_url"],
      body: %{
        token: workspace.slack_token,
        attachments: attachments
      }
    )
  end
end
