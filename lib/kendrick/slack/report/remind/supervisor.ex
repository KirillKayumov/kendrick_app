defmodule Kendrick.Slack.Report.Remind.Supervisor do
  use Supervisor

  alias Kendrick.Slack.Report.Remind.{
    UsersSupervisor,
    Starter
  }

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    children = [
      UsersSupervisor,
      %{
        id: Starter,
        start: {Starter, :start_link, [[]]},
        restart: :transient
      }
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
