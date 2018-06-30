defmodule Kendrick.Slack.Shared do
  alias Kendrick.{
    Users,
    Workspaces
  }

  def find_workspace(%{params: %{"team_id" => team_id}} = data), do: do_find_workspace(team_id, data)
  def find_workspace(%{params: %{"team" => %{"id" => team_id}}} = data), do: do_find_workspace(team_id, data)

  defp do_find_workspace(team_id, data) do
    workspace = Workspaces.get_by(team_id: team_id)

    {:ok, Map.put(data, :workspace, workspace)}
  end

  def find_user_slack_id(%{params: %{"user_id" => slack_id}} = data),
    do: do_find_user_slack_id(slack_id, data)

  def find_user_slack_id(%{params: %{"user" => %{"id" => slack_id}}} = data),
    do: do_find_user_slack_id(slack_id, data)

  defp do_find_user_slack_id(user_slack_id, data) do
    {:ok, Map.put(data, :user_slack_id, user_slack_id)}
  end

  def find_user(data) do
    {:ok, data} = find_user_slack_id(data)
    user = Users.get_by(slack_id: data.user_slack_id)

    {:ok, Map.put(data, :user, user)}
  end

  def find_channel(%{params: %{"channel_id" => channel}} = data), do: do_find_channel(channel, data)
  def find_channel(%{params: %{"channel" => %{"id" => channel}}} = data), do: do_find_channel(channel, data)

  defp do_find_channel(channel, data), do: {:ok, Map.put(data, :channel, channel)}
end
