defmodule Kendrick.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add(:name, :string, null: false)
      add(:project_id, references(:projects), null: false)

      timestamps()
    end

    create(index(:teams, :project_id))
    create(index(:teams, [:name, :project_id], unique: true))
  end
end
