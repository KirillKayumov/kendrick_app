defmodule Kendrick.Slack.ReviewReminders.Worker do
  use GenServer

  import Ecto.Query

  alias Kendrick.{
    Repo,
    Slack
  }

  @timeout 60_000

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(args) do
    schedule()

    {:ok, args}
  end

  def handle_info(:perform, state) do
    perform()
    schedule()

    {:noreply, state}
  end

  defp schedule do
    Process.send_after(self(), :perform, @timeout)
  end

  defp perform do
    Enum.each(reminders(), fn reminder ->
      remind(reminder)
      delete(reminder)
    end)
  end

  defp reminders do
    Slack.ReviewReminder
    |> where([r], r.remind_at < ^Timex.now())
    |> Repo.all()
  end

  defp remind(reminder) do
    Slack.Client.chat_post_ephemeral(%{
      channel: reminder.channel,
      text: "Yo, don't forget to take a look at #{reminder.url}",
      token: token(reminder),
      user: reminder.user_slack_id
    })
  end

  defp token(reminder) do
    reminder
    |> Ecto.assoc(:workspace)
    |> Repo.one()
    |> Map.get(:slack_token)
  end

  defp delete(reminder) do
    reminder |> Repo.delete!()
  end
end
