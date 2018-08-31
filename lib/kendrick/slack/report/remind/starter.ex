defmodule Kendrick.Slack.Report.Remind.Starter do
  use GenServer

  alias Kendrick.Slack.Report.Remind.UsersSupervisor

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(args) do
    UsersSupervisor.start_children()

    {:ok, args}
  end
end
