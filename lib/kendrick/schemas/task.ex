defmodule Kendrick.Task do
  use Ecto.Schema

  import Ecto.Changeset

  alias Kendrick.{
    Task,
    User
  }

  @finished_statuses ~w(
    acceptance
    closed
    done
    qa
    sred
  )

  schema "tasks" do
    field(:custom_status, :boolean)
    field(:disabled, :boolean)
    field(:finished_status_set_at, :utc_datetime)
    field(:status, :string)
    field(:title, :string)
    field(:type, :string)
    field(:url, :string)

    belongs_to(:user, User)

    timestamps()
  end

  def changeset(%Task{} = task, attrs \\ %{}) do
    task
    |> cast(attrs, [:title, :url, :status, :type, :disabled, :finished_status_set_at, :custom_status])
    |> validate_required([:title])
    |> track_finished_status()
  end

  defp track_finished_status(%{changes: %{status: new_status}} = changeset) do
    timestamp =
      case String.downcase(new_status) in @finished_statuses do
        true -> Kendrick.date_time().utc_now() |> Kendrick.date_time().truncate(:second)
        false -> nil
      end

    put_change(changeset, :finished_status_set_at, timestamp)
  end

  defp track_finished_status(changeset), do: changeset

  def color(%{disabled: true}), do: ""

  def color(%{type: type}) do
    case type do
      "Bug" -> "#DE4D33"
      "Design" -> "#FF9C23"
      "Epic" -> "#904EE2"
      "Fail Test" -> "#8095AA"
      "Story" -> "#63BA3C"
      "Sub-task" -> "#4BAEE8"
      "Task" -> "#4BADE8"
      _ -> ""
    end
  end
end
