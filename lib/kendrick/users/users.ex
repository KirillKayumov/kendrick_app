defmodule Kendrick.Users do
  alias Kendrick.Repo

  def for_workspace(workspace) do
    Ecto.assoc(workspace, :users) |> Repo.all()
  end
end
