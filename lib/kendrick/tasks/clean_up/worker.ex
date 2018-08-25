defmodule Kendrick.Tasks.CleanUp.Worker do
  use GenServer

  import Crontab.CronExpression
  import Ecto.Query

  alias Kendrick.{
    Repo,
    Scheduler,
    Task
  }

  @schedule ~e[0 0 * * *]

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def perform(pid) do
    GenServer.cast(pid, :perform)
  end

  def delete_job(pid, project_id) do
    GenServer.call(pid, {:delete_job, project_id})
  end

  def init(args) do
    state = %{
      project: args[:project],
      job_name: schedule_job()
    }

    {:ok, state}
  end

  def handle_cast(:perform, state) do
    do_perform(state[:project])

    {:noreply, state}
  end

  def handle_call({:delete_job, project_id}, _from, state) do
    response = do_delete_job(project_id, state)

    {:reply, response, state}
  end

  defp schedule_job do
    job =
      Scheduler.new_job()
      |> Quantum.Job.set_schedule(@schedule)
      |> Quantum.Job.set_task({__MODULE__, :perform, [self()]})

    Scheduler.add_job(job)

    job.name
  end

  defp do_perform(project) do
    tasks =
      from(t in Task,
        join: u in assoc(t, :user),
        join: p in assoc(u, :projects),
        where: t.finished_status_set_at < p.report_saved_at,
        where: p.id == ^project.id
      )

    Repo.delete_all(tasks)
  end

  def do_delete_job(project_id, state) do
    case project_id == state.project.id do
      true ->
        Scheduler.delete_job(state.job_name)
        :ok

      false ->
        :error
    end
  end
end
