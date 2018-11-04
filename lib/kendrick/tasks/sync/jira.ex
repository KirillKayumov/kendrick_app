defmodule Kendrick.Tasks.Sync.Jira do
  use GenServer

  import Crontab.CronExpression
  import Ecto.Query

  alias Kendrick.{
    Scheduler,
    User
  }

  @schedule ~e[*/15 * * * 1-5]

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(args) do
    state = %{
      project: args[:project],
      job_name: schedule_job()
    }

    {:ok, args}
  end

  def perform(pid) do
    GenServer.cast(pid, :perform)
  end

  def handle_cast(:perform, state) do
    do_perform(state[:project])

    {:noreply, state}
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
    project
    |> users()
    |> search_tasks()
#    |> create_or_update_tasks()
#    |> update_reports()
  end

  defp users(project) do
    users =
      from(u in Ecto.assoc(project, :users),
        preload: :tasks
      )

    Repo.all(users)
  end

  defp search_tasks(users) do

  end

#  defp search_tickets(email) do
#    [username, _] = String.split(email, "@")
#    query = %{
#      fields: ~w(summary status issuetype),
#      jql: """
#        status NOT IN (icebox, closed, Done, Acceptance)
#          AND NOT issuetype = Epic
#          AND assignee in (\"#{email}\", #{username})
#      """
#    }
#
#    Jira.API.search(query).body["issues"]
#
#  end
end
