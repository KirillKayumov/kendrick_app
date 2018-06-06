defmodule Kendrick.Slack.Events.Users.TeamJoin do
  alias Kendrick.{
    Repo,
    Workspace
  }

  def call(user) do
    user
    |> get_workspace()
    |> get_slack_users()
    |> append_new_user()
    |> update_workspace()
  end

  defp get_workspace(user) do
    workspace = Repo.get_by(Workspace, team_id: user["team_id"])

    { user, workspace }
  end

  defp get_slack_users({ user, workspace }) do
    { user, workspace, workspace.slack_users["list"] }
  end

  defp append_new_user({ user, workspace, slack_users }) do
    { user, workspace, slack_users ++ [user] }
  end

  defp update_workspace({ _user, workspace, slack_users }) do
    workspace
    |> Workspace.changeset(%{slack_users: %{list: slack_users }})
    |> Repo.update!()
  end
end
