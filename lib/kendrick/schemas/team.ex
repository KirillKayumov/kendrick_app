defmodule Kendrick.Team do
  use Ecto.Schema

  import Ecto.Changeset

  alias Kendrick.{
    Project,
    Team,
    User
  }

  schema "teams" do
    field(:name, :string)

    belongs_to(:project, Project)

    many_to_many(:users, User, join_through: "teams_users", on_replace: :delete, on_delete: :delete_all)

    timestamps()
  end

  def changeset(%Team{} = team, attrs \\ %{}) do
    team
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name, name: :teams_name_project_id_index)
  end
end
