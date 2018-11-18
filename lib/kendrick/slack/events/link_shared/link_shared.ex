defmodule Kendrick.Slack.Events.LinkShared do
  use GenServer

  @link_handlers %{
    "github.com" => Kendrick.Slack.Events.LinkShared.Github,
    "atlassian.net" => Kendrick.Slack.Events.LinkShared.Atlassian
  }

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

  defp do_call(%{"event" => %{"links" => links}} = params) do
    links = Enum.group_by(links, fn %{"domain" => domain} -> domain end)

    Enum.each(links, fn {domain, links} ->
      apply(@link_handlers[domain], :call, [%{links: links, params: params}])
    end)
  end
end
