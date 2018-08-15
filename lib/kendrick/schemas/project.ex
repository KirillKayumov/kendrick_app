defmodule Kendrick.Project do
  use Ecto.Schema

  import Ecto.Changeset

  alias Kendrick.{
    Project,
    Team,
    Workspace
  }

  schema "projects" do
    field(:name, :string)
    field(:report_saved_at, :utc_datetime)

    belongs_to(:workspace, Workspace)

    has_many(:teams, Team, on_delete: :delete_all)
    has_many(:users, through: [:teams, :users])

    timestamps()
  end

  def changeset(%Project{} = project, attrs \\ %{}) do
    project
    |> cast(attrs, [:name, :report_saved_at])
    |> validate_required([:name])
    |> unique_constraint(:name, name: :projects_name_workspace_id_index)
  end
end
