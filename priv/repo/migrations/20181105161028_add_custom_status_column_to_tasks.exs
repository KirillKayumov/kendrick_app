defmodule Kendrick.Repo.Migrations.AddCustomStatusColumnToTasks do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      add(:custom_status, :boolean, null: false, default: false)
    end
  end
end
