defmodule Kendrick.Repo.Migrations.AddFinishedStatusSetAtColumnToTasks do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      add(:finished_status_set_at, :utc_datetime)
    end
  end
end
