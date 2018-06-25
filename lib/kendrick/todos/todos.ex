defmodule Kendrick.Todos do
  import Ecto.Query

  alias Kendrick.{
    Repo,
    Task
  }

  def for_user(user) do
    user
    |> Ecto.assoc(:todos)
    |> order_by(:id)
    |> Repo.all()
  end
end
