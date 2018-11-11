defmodule Kendrick.Slack.Events.ReactionAdded.Numbers do
  import OK, only: [~>>: 2]
  import Kendrick.Slack.Shared, only: [find_workspace: 1]

  @minutes %{
    "one" => 10,
    "two" => 20,
    "three" => 30,
    "four" => 40,
    "five" => 50,
    "six" => 60,
    "seven" => 70,
    "eight" => 80,
    "nine" => 90
  }

  alias Kendrick.{
    Repo,
    Slack
  }

  def call(params) do
    %{params: params}
    |> find_workspace()
    ~>> should_create_review_reminder()
    ~>> create_review_reminder()
  end

  defp should_create_review_reminder(%{params: params} = data) do
    %{
      "event" => %{
        "item" => %{
          "channel" => channel,
          "ts" => ts
        }
      }
    } = params

    case Repo.get_by(Slack.SharedLink, ts: ts, channel: channel) do
      nil -> {:error, data}
      shared_link -> {:ok, Map.put(data, :shared_link, shared_link)}
    end
  end

  defp create_review_reminder(%{params: params, workspace: workspace, shared_link: shared_link}) do
    %{
      "event" => %{
        "event_ts" => event_ts,
        "item" => %{
          "channel" => channel
        },
        "reaction" => reaction,
        "user" => user_slack_id
      }
    } = params

    %Slack.ReviewReminder{}
    |> Slack.ReviewReminder.changeset(%{
      channel: channel,
      remind_at: remind_at(event_ts, reaction),
      url: shared_link.url,
      user_slack_id: user_slack_id
    })
    |> Ecto.Changeset.put_assoc(:workspace, workspace)
    |> Ecto.Changeset.cast_assoc(:workspace, required: true)
    |> Repo.insert!()
  end

  defp remind_at(event_ts, reaction) do
    event_ts
    |> Integer.parse()
    |> elem(0)
    |> Timex.from_unix()
    |> Timex.shift(minutes: @minutes[reaction])
  end
end
