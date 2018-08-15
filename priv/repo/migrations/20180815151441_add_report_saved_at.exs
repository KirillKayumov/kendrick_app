defmodule Kendrick.Repo.Migrations.AddReportSavedAt do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add(:report_saved_at, :utc_datetime)
    end
  end
end
