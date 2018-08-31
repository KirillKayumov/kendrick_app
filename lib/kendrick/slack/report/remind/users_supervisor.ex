defmodule Kendrick.Slack.Report.Remind.UsersSupervisor do
  use DynamicSupervisor

  alias Kendrick.Users
  alias Kendrick.Slack.Report.Remind.Worker

  def start_link(args) do
    DynamicSupervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_children do
    Enum.map(users(), &create_user/1)
  end

  def create_user(user) do
    DynamicSupervisor.start_child(__MODULE__, {Worker, user: user})
  end

  def delete_user(user_id) do
    __MODULE__
    |> DynamicSupervisor.which_children()
    |> Enum.each(fn {_, pid, _, _} ->
      case Worker.delete_job(pid, user_id) do
        :ok -> DynamicSupervisor.terminate_child(__MODULE__, pid)
        _ -> :ok
      end
    end)
  end

  defp users, do: Users.all()
end
