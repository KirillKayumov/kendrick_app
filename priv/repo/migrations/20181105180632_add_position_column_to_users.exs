defmodule Kendrick.Repo.Migrations.AddPositionColumnToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:position, :integer, null: false, default: 0)
    end
  end
end
