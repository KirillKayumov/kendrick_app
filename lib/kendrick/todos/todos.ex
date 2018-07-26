defmodule Kendrick.Todos do
  import Ecto.Query

  alias Kendrick.{
    Repo,
    Todo
  }

  def get(id) do
    Repo.get(Todo, id)
  end

  def for_user(user) do
    user
    |> Ecto.assoc(:todos)
    |> order_by([:done, :id])
    |> Repo.all()
  end
end
