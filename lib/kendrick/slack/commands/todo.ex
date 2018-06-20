defmodule Kendrick.Slack.Commands.Todo do
  use GenServer

  import OK, only: [~>>: 2]
  import Kendrick.Slack.Shared, only: [find_workspace: 1, find_user: 1, find_project: 1]

  alias Kendrick.{
    Repo,
    Slack,
    Todo
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
    |> find_workspace()
    ~>> find_user()
    ~>> find_project()
    ~>> build_changeset()
    ~>> validate_changeset()
    ~>> save_todo()
    |> post_result_message()

    {:noreply, state}
  end

  defp build_changeset(%{params: %{"text" => text}, user: user, project: project} = data) do
    changeset =
      %Todo{}
      |> Todo.changeset(%{text: text})
      |> Ecto.Changeset.put_assoc(:user, user)
      |> Ecto.Changeset.put_assoc(:project, project)
      |> Ecto.Changeset.cast_assoc(:user, required: true)
      |> Ecto.Changeset.cast_assoc(:project, required: true)

    {:ok, Map.put(data, :changeset, changeset)}
  end

  defp validate_changeset(%{changeset: changeset} = data) do
    case changeset.valid? do
      true -> {:ok, data}
      false -> {:error, data}
    end
  end

  defp save_todo(%{changeset: changeset} = data) do
    todo = Repo.insert!(changeset)

    {:ok, Map.put(data, :todo, todo)}
  end

  defp post_result_message({:ok, %{todo: todo} = data}) do
    post_message(":white_check_mark: To-do \"#{todo.text}\" was added.", data)
  end

  defp post_result_message({:error, %{changeset: changeset} = data}) do
    cond do
      changeset.errors[:project] -> post_no_project_message(data)
      changeset.errors[:text] -> post_no_text_message(data)
    end
  end

  defp post_no_project_message(data) do
    post_message(":warning: You can't create a to-do because you don't belong to any project.", data)
  end

  defp post_no_text_message(data) do
    post_message(":warning: Please provide text of to-do.", data)
  end

  defp post_message(text, data) do
    %{
      params: %{
        "channel_id" => channel,
        "user_id" => user
      },
      workspace: workspace
    } = data

    Slack.Client.chat_post_ephemeral(
      text,
      channel,
      user,
      workspace.slack_token
    )
  end
end
