defmodule Kendrick.Projects do
  alias Kendrick.{
    Project,
    Repo
  }

  def for_workspace(workspace) do
    Ecto.assoc(workspace, :projects) |> Repo.all()
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
