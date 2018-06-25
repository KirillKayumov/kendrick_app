defmodule Kendrick.Repo.Migrations.RemoveProjectIdColumnFromTodos do
  use Ecto.Migration

  def change do
    alter table(:todos) do
      remove(:project_id)
    end
  end
end
