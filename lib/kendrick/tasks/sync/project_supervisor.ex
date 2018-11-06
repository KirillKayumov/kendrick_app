defmodule Kendrick.Tasks.Sync.ProjectSupervisor do
  use Supervisor

  alias Kendrick.Tasks.Sync.{
    Jira,
    PivotalTracker
  }

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args)
  end

  def init(args) do
    children = [
      {Jira, args},
      {PivotalTracker, args}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
