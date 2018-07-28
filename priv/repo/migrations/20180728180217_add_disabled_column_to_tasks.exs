defmodule Kendrick.Repo.Migrations.AddDisabledColumnToTasks do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      add(:disabled, :boolean, null: false, default: false)
    end
  end
end
