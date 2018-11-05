defmodule Kendrick.Tasks.Sync.ProjectsSupervisor do
  use DynamicSupervisor

  alias Kendrick.Tasks.Sync.ProjectSupervisor

  def start_link(args) do
    DynamicSupervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_children do
    Enum.map(projects(), &create_project/1)
  end

  def create_project(project) do
    DynamicSupervisor.start_child(__MODULE__, {ProjectSupervisor, project: project})
  end

  #  def delete_project(project_id) do
  #    __MODULE__
  #    |> DynamicSupervisor.which_children()
  #    |> Enum.each(fn {_, pid, _, _} ->
  #      case Worker.delete_job(pid, project_id) do
  #        :ok -> DynamicSupervisor.terminate_child(__MODULE__, pid)
  #        _ -> :ok
  #      end
  #    end)
  #  end

  defp projects, do: Kendrick.Projects.all()
end
