defmodule Kendrick.Slack.SharedLink do
  use Ecto.Schema

  import Ecto.Changeset

  schema "shared_links" do
    field(:channel, :string)
    field(:ts, :string)
    field(:url, :string)
  end

  def changeset(%__MODULE__{} = task, attrs \\ %{}) do
    task
    |> cast(attrs, [:channel, :ts, :url])
    |> validate_required([:channel, :ts, :url])
  end
end
