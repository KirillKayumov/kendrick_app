defmodule Kendrick.Repo.Migrations.AddTypeColumnToTasks do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      add(:type, :string)
    end
  end
end
