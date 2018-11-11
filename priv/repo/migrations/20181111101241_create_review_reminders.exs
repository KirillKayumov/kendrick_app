defmodule Kendrick.Repo.Migrations.CreateReviewReminders do
  use Ecto.Migration

  def change do
    create table(:review_reminders) do
      add(:workspace_id, references(:workspaces), null: false)
      add(:user_slack_id, :string, null: false)
      add(:remind_at, :utc_datetime, null: false)
      add(:channel, :string, null: false)
      add(:text, :string, null: false)

      timestamps()
    end

    create(index(:review_reminders, :workspace_id))
  end
end
