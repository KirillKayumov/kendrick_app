defmodule Kendrick.Repo.Migrations.AddReportTsColumnToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:report_ts, :string)
    end
  end
end
