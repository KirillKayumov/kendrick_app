defmodule Kendrick.Slack.ReviewReminder do
  use Ecto.Schema

  import Ecto.Changeset

  alias Kendrick.{
    Workspace
  }

  schema "review_reminders" do
    field(:channel, :string)
    field(:remind_at, :utc_datetime)
    field(:url, :string)
    field(:user_slack_id, :string)

    belongs_to(:workspace, Workspace)

    timestamps()
  end

  def changeset(%__MODULE__{} = reminder, attrs \\ %{}) do
    reminder
    |> cast(attrs, [:channel, :remind_at, :url, :user_slack_id])
    |> validate_required([:channel, :remind_at, :url, :user_slack_id])
  end
end
