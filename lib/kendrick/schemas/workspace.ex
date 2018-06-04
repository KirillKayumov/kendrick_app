defmodule Kendrick.Workspace do
  use Ecto.Schema

  import Ecto.Changeset

  alias Kendrick.{
    User,
    Workspace
  }

  schema "workspaces" do
    field(:team_id, :string)

    has_many(:users, User, on_delete: :delete_all)

    timestamps()
  end

  def changeset(%Workspace{} = workspace, attrs) do
    workspace
    |> cast(attrs, [:team_id])
    |> validate_required([:team_id])
    |> unique_constraint(:team_id)
  end
end
