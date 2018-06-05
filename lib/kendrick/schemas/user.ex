defmodule Kendrick.User do
  use Ecto.Schema

  import Ecto.Changeset

  alias Kendrick.{
    User,
    Workspace
  }

  schema "users" do
    field(:slack_id, :string)
    field(:slack_token, :string)

    belongs_to(:workspace, Workspace)

    timestamps()
  end

  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:slack_id])
    |> validate_required([:slack_id])
    |> unique_constraint(:slack_id)
  end
end
