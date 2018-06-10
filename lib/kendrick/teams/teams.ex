defmodule Kendrick.Teams do
  import Ecto.Query, only: [order_by: 2]

  alias Kendrick.{
    Repo,
    Team,
    Users
  }

  def get(id) do
    Repo.get(Team, id)
  end

  def for_project(project) do
    project
    |> Ecto.assoc(:teams)
    |> order_by(:name)
    |> Repo.all()
  end

  def create(params, project) do
    %Team{}
    |> Team.changeset(params)
    |> Ecto.Changeset.put_assoc(:project, project)
    |> Repo.insert()
  end

  def update(team, params, workspace) do
    {user_ids, params} = Map.pop(params, "user_ids")

    team
    |> Map.put(:users, Users.for_team(team))
    |> Team.changeset(params)
    |> Ecto.Changeset.put_assoc(:users, accessible_users(user_ids, workspace))
    |> Repo.update()
  end

  def delete!(team) do
    Repo.delete!(team)
  end

  defp accessible_users(user_ids, workspace) do
    user_ids =
      user_ids
      |> Enum.filter(fn {_key, value} -> value == "true" end)
      |> Enum.map(fn {key, _value} -> key end)

    workspace
    |> Users.for_workspace()
    |> Enum.filter(fn user -> to_string(user.id) in user_ids end)
  end
end
