defmodule Kendrick.Project do
  use Ecto.Schema

  import Ecto.Changeset

  alias Kendrick.{
    Project,
    Workspace
  }

  schema "projects" do
    field(:name, :string)

    belongs_to(:workspace, Workspace)

    timestamps()
  end

  def changeset(%Project{} = project, attrs \\ %{}) do
    project
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name, name: :projects_name_workspace_id_index)
  end
end
