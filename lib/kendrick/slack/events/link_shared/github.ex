defmodule Kendrick.Slack.Events.LinkShared.Github do
  alias Kendrick.Repo
  alias Kendrick.Slack.SharedLink

  def call(%{links: links, params: params}) do
    %{
      "event" => %{
        "channel" => channel,
        "message_ts" => message_ts
      }
    } = params

    Enum.each(links, fn link ->
      %SharedLink{}
      |> SharedLink.changeset(%{channel: channel, ts: message_ts, url: link["url"]})
      |> Repo.insert!()
    end)
  end
end
