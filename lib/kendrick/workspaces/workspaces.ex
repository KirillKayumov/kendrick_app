defmodule Kendrick.Workspaces do
  alias Kendrick.{
    Repo,
    Slack,
    User,
    Workspace
  }

  def for_user(nil), do: nil

  def for_user(%User{workspace_id: workspace_id}) do
    Repo.get(Workspace, workspace_id)
  end

  def refresh_slack_users(workspace, current_user) do
    %{"members" => users} = Slack.Client.users_list(current_user.slack_token)

    workspace
    |> Workspace.changeset(%{slack_users: %{list: users}})
    |> Repo.update!()
  end
end
