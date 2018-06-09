defmodule Kendrick.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add(:name, :string, null: false)
      add(:workspace_id, references(:workspaces), null: false)

      timestamps()
    end

    create(index(:projects, :workspace_id))
    create(index(:projects, [:name, :workspace_id], unique: true))
  end
end
