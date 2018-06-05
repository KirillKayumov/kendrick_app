defmodule Kendrick.Repo.Migrations.AddSlackTokenColumnToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:slack_token, :string)
    end
  end
end
