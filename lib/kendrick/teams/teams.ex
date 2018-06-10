defmodule Kendrick.Teams do
  alias Kendrick.{
    Repo,
    Team
  }

  def for_project(project) do
    project
    |> Ecto.assoc(:teams)
    |> Repo.all()
  end

  def create(params, project) do
    %Team{}
    |> Team.changeset(params)
    |> Ecto.Changeset.put_assoc(:project, project)
    |> Repo.insert()
  end
end
