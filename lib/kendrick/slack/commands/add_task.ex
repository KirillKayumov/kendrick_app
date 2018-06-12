defmodule Kendrick.Slack.Commands.AddTask do
  use GenServer

  alias Kendrick.{
    Repo,
    Slack,
    Task,
    Users,
    Workspaces
  }

  @name :slack_commands_add_task_worker

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
    |> get_jira_task_details()
    |> save_task()
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

  defp get_jira_task_details(%{params: params} = data) do
    task_text = String.trim(params["text"])
    jira_data = Jira.API.ticket_details(task_text)

    data
    |> Map.put(:task_text, task_text)
    |> Map.put(:jira_data, jira_data)
  end

  defp save_task(%{jira_data: jira_data} = data) do
    case Map.has_key?(jira_data, "errors") do
      true -> save_regular_task(data)
      false -> save_jira_task(data)
    end
  end

  defp save_regular_task(%{task_text: task_text, user: user} = data) do
    task =
      %Task{}
      |> Task.changeset(%{title: task_text})
      |> Ecto.Changeset.put_assoc(:user, user)
      |> Repo.insert!()

    Map.put(data, :task, task)
  end

  defp save_jira_task(%{jira_data: jira_data, user: user} = data) do
    task =
      %Task{}
      |> Task.changeset(Kendrick.Jira.Task.to_map(jira_data))
      |> Ecto.Changeset.put_assoc(:user, user)
      |> Repo.insert!()

    Map.put(data, :task, task)
  end

  defp post_message(%{task: task, user: user, workspace: workspace}) do
    %{
      status: task.status,
      url: task.url,
      title: task.title
    }
    |> Poison.encode!()
    |> Slack.Client.post_message(user.slack_channel, workspace.slack_token)
  end
end
