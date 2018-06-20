defmodule Kendrick.Slack.Actions.Tasks.StatusUpdate do
  use GenServer

  alias Kendrick.{
    Repo,
    Slack,
    Task,
    Tasks,
    Users,
    Workspaces
  }

  @name :slack_actions_tasks_status_update_worker

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
    |> get_user()
    |> get_workspace()
    |> get_task()
    |> update_status()
    |> build_report()
    |> post_report()

    {:noreply, state}
  end

  defp get_user(%{params: params} = data) do
    user = Users.get_by(slack_id: params["user"]["id"])

    Map.put(data, :user, user)
  end

  defp get_workspace(%{params: params} = data) do
    workspace = Workspaces.get_by(team_id: params["team"]["id"])

    Map.put(data, :workspace, workspace)
  end

  defp get_task(%{params: params} = data) do
    task = Tasks.get(params["callback_id"])

    Map.put(data, :task, task)
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

    data
  end

  defp build_report(%{user: user} = data) do
    attachments = Slack.Report.build(user)

    Map.put(data, :attachments, attachments)
  end

  defp post_report(%{params: params, workspace: workspace, attachments: attachments}) do
    Slack.Client.respond(
      url: params["response_url"],
      body: %{
        token: workspace.slack_token,
        attachments: attachments
      }
    )
  end
end
