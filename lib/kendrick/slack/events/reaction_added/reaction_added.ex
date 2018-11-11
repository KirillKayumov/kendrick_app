defmodule Kendrick.Slack.Events.ReactionAdded do
  use GenServer

  @numbers ~w(
    one
    two
    three
    four
    five
    six
    seven
    eight
    nine
  )

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

  defp do_call(%{"event" => %{"reaction" => reaction}} = params) when reaction in @numbers do
    Kendrick.Slack.Events.ReactionAdded.Numbers.call(params)
  end

  defp do_call(params), do: params
end
