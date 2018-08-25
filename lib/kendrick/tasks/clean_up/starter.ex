defmodule Kendrick.Tasks.CleanUp.Starter do
  use GenServer

  alias Kendrick.Tasks.CleanUp.ProjectsSupervisor

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(args) do
    ProjectsSupervisor.start_children()

    {:ok, args}
  end
end
