defmodule Kendrick.Slack.Commands.Todo do
  use GenServer

  import OK, only: [~>>: 2]
  import Kendrick.Slack.Shared, only: [find_workspace: 1, find_user: 1]

  alias Kendrick.{
    Repo,
    Slack,
    Todo
  }

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def create(params) do
    GenServer.cast(__MODULE__, {:create, params})
  end

  def init(args) do
    {:ok, args}
  end

  def handle_cast({:create, params}, state) do
    %{params: params}
    |> find_workspace()
    ~>> find_user()
    ~>> build_changeset()
    ~>> validate_changeset()
    ~>> save_todo()
    |> post_result_message()
    ~>> update_report()

    {:noreply, state}
  end

  defp build_changeset(%{params: %{"text" => text}, user: user} = data) do
    changeset =
      %Todo{}
      |> Todo.changeset(%{text: text})
      |> Ecto.Changeset.put_assoc(:user, user)
      |> Ecto.Changeset.cast_assoc(:user, required: true)

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
    post_message(":white_check_mark: Todo \"#{todo.text}\" was added.", data)

    {:ok, data}
  end

  defp post_result_message({:error, %{changeset: changeset} = data}) do
    cond do
      changeset.errors[:text] -> post_no_text_message(data)
    end

    {:error, data}
  end

  defp post_no_text_message(data) do
    post_message(":warning: Please provide text of todo.", data)
  end

  defp post_message(text, data) do
    %{
      params: %{
        "channel_id" => channel,
        "user_id" => user
      },
      workspace: workspace
    } = data

    Slack.Client.chat_post_ephemeral(%{
      channel: channel,
      text: text,
      token: workspace.slack_token,
      user: user
    })
  end

  defp update_report(%{user: user, workspace: workspace}) do
    attachments = Slack.Report.build(user)

    Slack.Client.chat_update(%{
      attachments: attachments,
      channel: user.slack_channel,
      token: workspace.slack_token,
      ts: user.report_ts
    })
  end
end
