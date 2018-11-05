defmodule Kendrick.Tasks.Sync.Jira do
  use GenServer

  import Crontab.CronExpression
  import Ecto.Query

  alias Kendrick.{
    Repo,
    Scheduler,
    Slack,
    Task
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

    {:ok, state}
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
    |> load_users()
    |> search_tasks()
    |> create_or_update_tasks()
    |> update_reports()
  end

  defp load_users(project) do
    users = from(u in Ecto.assoc(project, :users), preload: [:workspace, :tasks])

    Repo.all(users)
  end

  defp search_tasks(users) do
    Enum.map(users, fn user ->
      query = search_tickets_query(user.email)

      {user, Jira.API.search(query).body["issues"]}
    end)
  end

  defp search_tickets_query(email) do
    [username, _] = String.split(email, "@")

    %{
      fields: ~w(summary status issuetype),
      jql: """
        status NOT IN (icebox, closed, Done, Acceptance)
          AND NOT issuetype = Epic
          AND assignee in (\"#{email}\", #{username})
      """
    }
  end

  defp create_or_update_tasks(users_with_tasks) do
    Enum.map(users_with_tasks, fn {user, tasks} ->
      Enum.each(tasks, fn task ->
        jira_task = Kendrick.Jira.Task.to_map(task)

        update_task(jira_task, user) || create_task(jira_task, user)
      end)

      {user, tasks}
    end)
  end

  defp update_task(jira_task, user) do
    task = Enum.find(user.tasks, fn user_task -> user_task.url == jira_task.url end)

    case task do
      nil ->
        false

      _ ->
        task
        |> Task.changeset(jira_task)
        |> Repo.update!()
    end
  end

  defp create_task(jira_task, user) do
    %Task{}
    |> Task.changeset(jira_task)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Ecto.Changeset.cast_assoc(:user, required: true)
    |> Repo.insert!()
  end

  defp update_reports(users_with_tasks) do
    Enum.each(users_with_tasks, fn {user, _} ->
      attachments = Slack.Report.build(user)

      Slack.Client.chat_update(%{
        attachments: attachments,
        channel: user.slack_channel,
        token: user.workspace.slack_token,
        ts: user.report_ts
      })
    end)
  end
end
