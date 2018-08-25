defmodule Kendrick.Tasks.CleanUp.Supervisor do
  use Supervisor

  alias Kendrick.Tasks.CleanUp.{
    ProjectsSupervisor,
    Starter
  }

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    children = [
      ProjectsSupervisor,
      %{
        id: Starter,
        start: {Starter, :start_link, [[]]},
        restart: :transient
      }
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
