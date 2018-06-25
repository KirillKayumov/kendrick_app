defmodule Kendrick.Todo do
  use Ecto.Schema

  import Ecto.Changeset

  alias Kendrick.{
    Todo,
    User
  }

  schema "todos" do
    field(:text, :string)
    field(:done, :boolean)

    belongs_to(:user, User)

    timestamps()
  end

  def changeset(%Todo{} = todo, attrs \\ %{}) do
    todo
    |> cast(attrs, [:text, :done])
    |> validate_required([:text])
  end
end
