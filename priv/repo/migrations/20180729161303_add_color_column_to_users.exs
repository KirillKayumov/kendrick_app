defmodule Kendrick.Repo.Migrations.AddColorColumnToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:color, :string, null: false)
    end
  end
end
