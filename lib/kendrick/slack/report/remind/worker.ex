defmodule Kendrick.Slack.Report.Remind.Worker do
  use GenServer

  import Crontab.CronExpression

  alias Kendrick.{
    Scheduler,
    Slack,
    Workspaces
  }

  @schedule ~e[15 11 * * 1-5]

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def perform(pid) do
    GenServer.cast(pid, :perform)
  end

  def delete_job(pid, user_id) do
    GenServer.call(pid, {:delete_job, user_id})
  end

  def init(args) do
    state = %{
      user: args[:user],
      job_name: schedule_job().name
    }

    {:ok, state}
  end

  def handle_cast(:perform, state) do
    do_perform(state[:user])

    {:noreply, state}
  end

  def handle_call({:delete_job, user_id}, _from, state) do
    response = do_delete_job(user_id, state)

    {:reply, response, state}
  end

  defp schedule_job do
    Scheduler.create_job(%{
      schedule: @schedule,
      task: {__MODULE__, :perform, [self()]}
    })
  end

  defp do_perform(user) do
    %{user: user}
    |> get_workspace()
    |> post_report()
  end

  defp get_workspace(%{user: user} = data) do
    workspace = Workspaces.for_user(user)

    Map.put(data, :workspace, workspace)
  end

  defp post_report(%{user: user, workspace: workspace}) do
    Slack.Report.Post.call(user, workspace)
  end

  def do_delete_job(user_id, state) do
    case user_id == state.user.id do
      true ->
        Scheduler.delete_job(state.job_name)
        :ok

      false ->
        :error
    end
  end
end
