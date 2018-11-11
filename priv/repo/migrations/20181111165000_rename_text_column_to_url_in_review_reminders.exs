defmodule Kendrick.Repo.Migrations.RenameTextColumnToUrlInReviewReminders do
  use Ecto.Migration

  def change do
    rename(table(:review_reminders), :text, to: :url)
  end
end
