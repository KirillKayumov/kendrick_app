defmodule Kendrick.Repo.Migrations.CreateTeamsUsers do
  use Ecto.Migration

  def change do
    create table(:teams_users, primary_key: false) do
      add(:team_id, references(:teams), null: false)
      add(:user_id, references(:users), null: false)
    end

    create(index(:teams_users, [:team_id, :user_id], unique: true))
  end
end
