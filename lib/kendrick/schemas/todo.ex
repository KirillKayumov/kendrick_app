defmodule Kendrick.Todo do
  use Ecto.Schema

  import Ecto.Changeset

  alias Kendrick.{
    Project,
    Todo,
    User
  }

  schema "todos" do
    field(:text, :string)

    belongs_to(:user, User)

    timestamps()
  end

  def changeset(%Todo{} = todo, attrs \\ %{}) do
    todo
    |> cast(attrs, [:text])
    |> validate_required([:text])
  end
end
