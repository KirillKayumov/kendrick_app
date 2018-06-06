defmodule Kendrick.Repo.Migrations.AddSlackUsersColumnToWorkspaces do
  use Ecto.Migration

  def change do
    alter table(:workspaces) do
      add :slack_users, :jsonb
    end
  end
end
