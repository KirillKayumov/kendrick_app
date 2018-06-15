defmodule Kendrick.Slack.Commands.Todo do
  use GenServer

  alias Kendrick.{
    Projects,
    Repo,
    Slack,
    Todo,
    Users,
    Workspaces
  }

  @name :slack_commands_todo_worker

  def start_link do
    GenServer.start_link(__MODULE__, [], name: @name)
  end

  def create(params) do
    GenServer.cast(@name, {:create, params})
  end

  def init(args) do
    {:ok, args}
  end

  def handle_cast({:create, params}, state) do
    %{params: params}
    |> get_user()
    |> get_project()
    |> get_workspace()
    |> do_create()
    |> post_result()

    {:noreply, state}
  end

  defp get_user(%{params: params} = data) do
    user = Users.get_by(slack_id: params["user_id"])

    Map.put(data, :user, user)
  end

  defp get_project(%{user: user} = data) do
    project = Projects.for_user(user)

    Map.put(data, :project, project)
  end

  defp get_workspace(%{params: params} = data) do
    workspace = Workspaces.get_by(team_id: params["team_id"])

    Map.put(data, :workspace, workspace)
  end

  defp do_create(%{params: %{"text" => text}, user: user, project: project} = data) do
    changeset =
      %Todo{}
      |> Todo.changeset(%{text: text})
      |> Ecto.Changeset.put_assoc(:user, user)
      |> Ecto.Changeset.put_assoc(:project, project)

    data =
      case changeset.valid? do
        true ->
          todo = Repo.insert!(changeset)
          Map.put(data, :todo, todo)

        false ->
          Map.put(data, :error, ":warning: Please provide text of to-do.")
      end

    data
  end

  defp post_result(%{error: error} = data) do
    %{
      params: %{
        "channel_id" => channel,
        "user_id" => user
      },
      workspace: %{
        slack_token: token
      }
    } = data

    Slack.Client.chat_post_ephemeral(error, channel, user, token)
  end

  defp post_result(data) do
    %{
      params: %{
        "channel_id" => channel,
        "user_id" => user
      },
      workspace: %{
        slack_token: token
      },
      todo: %{
        text: text
      }
    } = data

    Slack.Client.chat_post_ephemeral(":white_check_mark: To-do \"#{text}\" was added.", channel, user, token)
  end
end
