defmodule Kendrick.Slack.Shared do
  alias Kendrick.{
    Projects,
    Users,
    Workspaces
  }

  def find_workspace(%{params: %{"team_id" => team_id}} = data), do: do_find_workspace(team_id, data)
  def find_workspace(%{params: %{"team" => %{"id" => team_id}}} = data), do: do_find_workspace(team_id, data)

  defp do_find_workspace(team_id, data) do
    workspace = Workspaces.get_by(team_id: team_id)

    {:ok, Map.put(data, :workspace, workspace)}
  end

  def find_user_slack_id(data), do: {:ok, Map.put(data, :user_slack_id, user_slack_id(data))}

  defp user_slack_id(%{params: %{"user_id" => slack_id}}), do: slack_id
  defp user_slack_id(%{params: %{"user" => %{"id" => slack_id}}}), do: slack_id

  def find_user(data) do
    user = Users.get_by(slack_id: user_slack_id(data))

    {:ok, Map.put(data, :user, user)}
  end

  def user_from_callback_id(%{callback_id: %{"user_id" => user_id}}), do: Users.get(user_id)
  def user_from_callback_id(_data), do: nil

  def find_channel(%{params: %{"channel_id" => channel}} = data), do: do_find_channel(channel, data)
  def find_channel(%{params: %{"channel" => %{"id" => channel}}} = data), do: do_find_channel(channel, data)

  defp do_find_channel(channel, data), do: {:ok, Map.put(data, :channel, channel)}

  def encode_callback_id(data) do
    Poison.encode!(data)
  end

  def decode_callback_id(%{params: %{"callback_id" => callback_id}} = data) do
    callback_id = Poison.decode!(callback_id)

    {:ok, Map.put(data, :callback_id, callback_id)}
  end

  def find_project(%{callback_id: %{"project_id" => project_id}} = data) do
    project = Projects.get(project_id)

    {:ok, Map.put(data, :project, project)}
  end

  def find_project(data), do: {:ok, data}
end
