defmodule Kendrick.Repo.Migrations.AddForReportsColumnToTeams do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add(:for_reports, :boolean, null: false, default: true)
    end
  end
end
