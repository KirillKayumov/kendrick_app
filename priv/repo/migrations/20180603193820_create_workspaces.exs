defmodule Kendrick.Repo.Migrations.CreateWorkspaces do
  use Ecto.Migration

  def change do
    create table(:workspaces) do
      add(:team_id, :string, null: false)

      timestamps()
    end

    create(index(:workspaces, :team_id, unique: true))
  end
end
