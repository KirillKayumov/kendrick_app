defmodule Kendrick.Repo.Migrations.RenameCompletedColumnInTodos do
  use Ecto.Migration

  def change do
    rename(table(:todos), :completed, to: :done)
  end
end
