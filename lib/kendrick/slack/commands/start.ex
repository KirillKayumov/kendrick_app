defmodule Kendrick.Slack.Commands.Start do
  use GenServer

  alias Kendrick.{
    Repo,
    Slack,
    User,
    Users,
    Workspace
  }

  @name :slack_commands_start_worker

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
    workspace = find_workspace(params)

    case do_call(params, workspace) do
      :created -> post_created_message(params, workspace)
      :found -> post_found_message(params, workspace)
    end

    {:noreply, state}
  end

  defp find_workspace(%{"team_id" => team_id}) do
    Repo.get_by(Workspace, team_id: team_id)
  end

  defp do_call(params, workspace) do
    case Users.get_by(slack_id: params["user_id"]) do
      nil ->
        create_user(params, workspace)
        :created

      _ ->
        :found
    end
  end

  defp create_user(params, workspace) do
    %{
      "channel_id" => slack_channel,
      "user_id" => slack_id
    } = params

    name = get_name(params, workspace)

    %User{}
    |> User.changeset(%{slack_id: slack_id, name: name, slack_channel: slack_channel})
    |> Ecto.Changeset.put_assoc(:workspace, workspace)
    |> Repo.insert!()
  end

  defp get_name(%{"user_id" => user_id}, %{slack_token: slack_token}) do
    response = Slack.Client.profile_get(user_id, slack_token)

    response["profile"]["real_name"]
  end

  defp post_created_message(%{"channel_id" => channel_id}, %{slack_token: slack_token}) do
    Slack.Client.post_message("The app was started for you :tada:", channel_id, slack_token)
  end

  defp post_found_message(%{"channel_id" => channel_id}, %{slack_token: slack_token}) do
    Slack.Client.post_message("You already started the app.", channel_id, slack_token)
  end
end
