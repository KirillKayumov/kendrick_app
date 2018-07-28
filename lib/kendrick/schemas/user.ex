defmodule Kendrick.User do
  use Ecto.Schema

  import Ecto.Changeset

  alias Kendrick.{
    Task,
    Team,
    Todo,
    User,
    Workspace
  }

  schema "users" do
    field(:slack_id, :string)
    field(:name, :string)
    field(:slack_channel, :string)
    field(:rewards_token, :string)
    field(:report_ts, :string)
    field(:absence, :string)

    belongs_to(:workspace, Workspace)

    has_many(:tasks, Task, on_delete: :delete_all)
    has_many(:todos, Todo, on_delete: :delete_all)

    many_to_many(:teams, Team, join_through: "teams_users", on_delete: :delete_all)

    has_many(:projects, through: [:teams, :project])

    timestamps()
  end

  def changeset(%User{} = user, attrs \\ %{}) do
    user
    |> cast(attrs, [:slack_id, :name, :slack_channel, :rewards_token, :report_ts, :absence])
    |> validate_required([:slack_id, :slack_channel])
    |> unique_constraint(:slack_id)
  end
end
