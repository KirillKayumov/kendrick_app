defmodule Kendrick.Repo.Migrations.AddUniqueIndexForSlackIdColumn do
  use Ecto.Migration

  def change do
    create(index(:users, :slack_id, unique: true))
  end
end
