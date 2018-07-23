defmodule Kendrick.Users do
  import Ecto.Query, only: [order_by: 2]

  alias Kendrick.{
    Repo,
    User
  }

  def get(id) do
    Repo.get(User, id)
  end

  def get_by(attrs) do
    Repo.get_by(User, attrs)
  end

  def for_workspace(workspace) do
    workspace
    |> Ecto.assoc(:users)
    |> order_by(:name)
    |> Repo.all()
  end

  def for_team(team) do
    team
    |> Ecto.assoc(:users)
    |> order_by(:name)
    |> Repo.all()
  end

  def workspace_members(workspace) do
    workspace
    |> for_workspace()
    |> filter_out_users_from(workspace.slack_users["list"])
  end

  defp filter_out_users_from(users, slack_users) do
    slack_ids = Enum.map(users, & &1.slack_id)

    Enum.filter(slack_users, &(&1["id"] not in slack_ids))
  end
end
