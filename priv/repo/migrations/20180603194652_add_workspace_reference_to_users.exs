defmodule Kendrick.Repo.Migrations.AddWorkspaceReferenceToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:workspace_id, references(:workspaces), null: false)
    end

    create(index(:users, :workspace_id))
  end
end
