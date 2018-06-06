defmodule Kendrick.Users do
  alias Kendrick.Repo

  def for_workspace(workspace) do
    Ecto.assoc(workspace, :users) |> Repo.all()
  end

  def workspace_members(workspace) do
    workspace
    |> for_workspace()
    |> filter_out_users_from(workspace.slack_users["list"])
  end

  defp filter_out_users_from(users, slack_users) do
    slack_ids = Enum.map(users, &(&1.slack_id))

    Enum.filter(slack_users, &(&1["id"] not in slack_ids))
  end
end
