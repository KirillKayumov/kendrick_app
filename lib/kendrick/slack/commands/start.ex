defmodule Kendrick.Slack.Commands.Start do
  use GenServer

  import OK, only: [~>>: 2]
  import Kendrick.Slack.Shared, only: [find_workspace: 1]

  alias Kendrick.{
    Repo,
    Slack,
    User,
    Users
  }

  @name :slack_commands_start_worker

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
    |> ensure_no_user()
    ~>> find_workspace()
    ~>> create_user()
    |> post_message()

    {:noreply, state}
  end

  defp ensure_no_user(%{params: params} = data) do
    case Users.get_by(slack_id: params["user_id"]) do
      nil -> {:ok, data}
      _ -> {:error, {:user_exists, data}}
    end
  end

  defp create_user(%{params: params, workspace: workspace} = data) do
    %{
      "channel_id" => slack_channel,
      "user_id" => slack_id
    } = params

    user =
      %User{}
      |> User.changeset(%{slack_id: slack_id, name: user_name(data), slack_channel: slack_channel})
      |> Ecto.Changeset.put_assoc(:workspace, workspace)
      |> Ecto.Changeset.cast_assoc(:workspace, required: true)
      |> Repo.insert!()

    {:ok, Map.put(data, :user, user)}
  end

  defp user_name(%{params: %{"user_id" => user_id}, workspace: workspace}) do
    response = Slack.Client.profile_get(user_id, workspace.slack_token)

    response["profile"]["real_name"]
  end

  defp post_message({:ok, data}) do
    do_post_message("The app was started for you :tada:", data)
  end

  defp post_message({:error, {:user_exists, data}}) do
    do_post_message("You already started the app.", data)
  end

  defp do_post_message(message, %{params: %{"channel_id" => channel_id}, workspace: workspace}) do
    Slack.Client.post_message(message, channel_id, workspace.slack_token)
  end
end
