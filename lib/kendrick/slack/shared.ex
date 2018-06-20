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

  def find_user(%{params: %{"user_id" => slack_id}} = data), do: do_find_user(slack_id, data)
  def find_user(%{params: %{"user" => %{"id" => slack_id}}} = data), do: do_find_user(slack_id, data)

  defp do_find_user(slack_id, data) do
    user = Users.get_by(slack_id: slack_id)

    {:ok, Map.put(data, :user, user)}
  end

  def find_project(%{user: user} = data) do
    project = Projects.for_user(user)

    {:ok, Map.put(data, :project, project)}
  end
end
