defmodule Kendrick.Repo.Migrations.AddRewardsTokenColumnToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:rewards_token, :string)
    end
  end
end
