defmodule Kendrick.Repo.Migrations.CreateSharedLinks do
  use Ecto.Migration

  def change do
    create table(:shared_links) do
      add(:channel, :string, null: false)
      add(:ts, :string, null: false)
      add(:url, :string, null: false)
    end

    create(index(:shared_links, [:ts, :channel]))
  end
end
