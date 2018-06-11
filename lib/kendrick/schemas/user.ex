defmodule Kendrick.User do
  use Ecto.Schema

  import Ecto.Changeset

  alias Kendrick.{
    Team,
    User,
    Workspace
  }

  schema "users" do
    field(:slack_id, :string)
    field(:name, :string)

    belongs_to(:workspace, Workspace)

    many_to_many(:teams, Team, join_through: "teams_users", on_delete: :delete_all)

    timestamps()
  end

  def changeset(%User{} = user, attrs \\ %{}) do
    user
    |> cast(attrs, [:slack_id, :name])
    |> validate_required([:slack_id])
    |> unique_constraint(:slack_id)
  end
end
