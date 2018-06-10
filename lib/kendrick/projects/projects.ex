defmodule Kendrick.Projects do
  import Ecto.Query, only: [order_by: 2]

  alias Kendrick.{
    Project,
    Repo
  }

  def get(id) do
    Repo.get(Project, id)
  end

  def for_workspace(workspace) do
    Ecto.assoc(workspace, :projects)
    |> order_by(:name)
    |> Repo.all()
  end

  def create(params, workspace) do
    %Project{}
    |> Project.changeset(params)
    |> Ecto.Changeset.put_assoc(:workspace, workspace)
    |> Repo.insert()
  end

  def delete(id) do
    Project
    |> Repo.get(id)
    |> Repo.delete!()
  end
end