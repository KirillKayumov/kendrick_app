defmodule Kendrick.Task do
  use Ecto.Schema

  import Ecto.Changeset

  alias Kendrick.{
    Task,
    User
  }

  schema "tasks" do
    field(:title, :string)
    field(:url, :string)
    field(:status, :string)
    field(:type, :string)

    belongs_to(:user, User)

    timestamps()
  end

  def changeset(%Task{} = task, attrs \\ %{}) do
    task
    |> cast(attrs, [:title, :url, :status, :type])
    |> validate_required([:title])
  end
end
