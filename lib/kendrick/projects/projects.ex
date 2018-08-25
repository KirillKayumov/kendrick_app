defmodule Kendrick.Projects do
  import Ecto.Query

  alias Kendrick.{
    Project,
    Repo,
    Tasks
  }

  def all(query \\ Project) do
    Repo.all(query)
  end

  def get(id) do
    Repo.get(Project, id)
  end

  def for_workspace(workspace) do
    Ecto.assoc(workspace, :projects)
    |> order_by(:name)
    |> Repo.all()
  end

  def for_user(user) do
    Ecto.assoc(user, :projects)
    |> first()
    |> Repo.one()
  end

  def create(params, workspace) do
    result =
      %Project{}
      |> Project.changeset(params)
      |> Ecto.Changeset.put_assoc(:workspace, workspace)
      |> Repo.insert()

    case result do
      {:ok, project} ->
        Tasks.CleanUp.ProjectsSupervisor.create_project(project)
        result

      _ ->
        result
    end
  end

  def delete(id) do
    Project
    |> Repo.get(id)
    |> Repo.delete!()

    Tasks.CleanUp.ProjectsSupervisor.delete_project(id)
  end
end
