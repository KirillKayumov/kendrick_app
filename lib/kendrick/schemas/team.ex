defmodule Kendrick.Team do
  use Ecto.Schema

  import Ecto.Changeset

  alias Kendrick.{
    Team,
    Project
  }

  schema "teams" do
    field(:name, :string)

    belongs_to(:project, Project)

    timestamps()
  end

  def changeset(%Team{} = team, attrs \\ %{}) do
    team
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name, name: :team_name_project_id_index)
  end
end
