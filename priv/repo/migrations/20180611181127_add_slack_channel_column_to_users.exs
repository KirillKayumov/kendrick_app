defmodule Kendrick.Repo.Migrations.AddSlackChannelColumnToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:slack_channel, :string, null: false)
    end
  end
end
