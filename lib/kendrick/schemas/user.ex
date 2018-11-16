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
    field(:absence, :string)
    field(:color, :string)
    field(:email, :string)
    field(:name, :string)
    field(:position, :integer)
    field(:report_ts, :string)
    field(:rewards_token, :string)
    field(:slack_channel, :string)
    field(:slack_id, :string)
    field(:slack_token, :string)

    belongs_to(:workspace, Workspace)

    has_many(:tasks, Task, on_delete: :delete_all)
    has_many(:todos, Todo, on_delete: :delete_all)

    many_to_many(:teams, Team, join_through: "teams_users", on_delete: :delete_all)

    has_many(:projects, through: [:teams, :project])

    timestamps()
  end

  def changeset(%User{} = user, attrs \\ %{}) do
    user
    |> cast(attrs, [
      :absence,
      :color,
      :email,
      :name,
      :position,
      :report_ts,
      :rewards_token,
      :slack_channel,
      :slack_id,
      :slack_token
    ])
    |> validate_required([:email, :slack_id, :slack_channel])
    |> unique_constraint(:slack_id)
  end
end
