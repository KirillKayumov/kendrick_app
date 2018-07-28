defmodule Kendrick.Tasks do
  import Ecto.Query

  alias Kendrick.{
    Repo,
    Task
  }

  def get(id) do
    Repo.get(Task, id)
  end

  def for_user(user) do
    user
    |> Ecto.assoc(:tasks)
    |> order_by([:disabled, :id])
    |> Repo.all()
  end
end
