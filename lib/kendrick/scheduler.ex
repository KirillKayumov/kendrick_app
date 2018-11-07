defmodule Kendrick.Scheduler do
  use Quantum.Scheduler, otp_app: :kendrick

  @default_timezone Application.get_env(:quantum, :timezone)

  def create_job(%{schedule: schedule, task: task} = config) do
    new_job()
    |> Quantum.Job.set_schedule(schedule)
    |> Quantum.Job.set_task(task)
    |> assign_timezone(config)
    |> do_add_job()
  end

  defp assign_timezone(job, %{timezone: timezone}), do: Quantum.Job.set_timezone(job, timezone)

  defp assign_timezone(job, _), do: Quantum.Job.set_timezone(job, @default_timezone)

  defp do_add_job(job) do
    add_job(job)

    job
  end
end
