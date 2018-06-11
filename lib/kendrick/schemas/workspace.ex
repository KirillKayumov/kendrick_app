defmodule Kendrick.Workspace do
  use Ecto.Schema

  import Ecto.Changeset

  alias Kendrick.{
    Project,
    User,
    Workspace
  }

  schema "workspaces" do
    field(:team_id, :string)
    field(:slack_token, :string)

    has_many(:users, User, on_delete: :delete_all)
    has_many(:projects, Project, on_delete: :delete_all)

    timestamps()
  end

  def changeset(%Workspace{} = workspace, attrs \\ %{}) do
    workspace
    |> cast(attrs, [:team_id, :slack_token])
    |> validate_required([:team_id, :slack_token])
    |> unique_constraint(:team_id)
  end
end
