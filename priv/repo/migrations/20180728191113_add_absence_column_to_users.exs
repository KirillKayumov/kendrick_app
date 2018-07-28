defmodule Kendrick.Repo.Migrations.AddAbsenceColumnToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:absence, :string)
    end
  end
end
