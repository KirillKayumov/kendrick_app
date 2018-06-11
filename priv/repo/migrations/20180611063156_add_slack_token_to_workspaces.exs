defmodule Kendrick.Repo.Migrations.AddSlackTokenToWorkspaces do
  use Ecto.Migration

  def change do
    alter table(:workspaces) do
      add(:slack_token, :string, null: false)
    end
  end
end
