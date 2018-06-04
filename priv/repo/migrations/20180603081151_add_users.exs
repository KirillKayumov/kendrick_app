defmodule Kendrick.Repo.Migrations.AddUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:slack_id, :string, null: false)

      timestamps()
    end
  end
end
