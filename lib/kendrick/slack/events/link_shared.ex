defmodule Kendrick.Slack.Events.LinkShared do
  use GenServer

  alias Kendrick.Repo
  alias Kendrick.Slack.SharedLink

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def call(params) do
    GenServer.cast(__MODULE__, {:call, params})
  end

  def init(args) do
    {:ok, args}
  end

  def handle_cast({:call, params}, state) do
    do_call(params)

    {:noreply, state}
  end

  defp do_call(params) do
    %{
      "event" => %{
        "channel" => channel,
        "links" => links,
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
