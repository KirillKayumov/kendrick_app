defmodule Kendrick.Tasks.CleanUp.Worker do
  use GenServer

  import Crontab.CronExpression
  import Ecto.Query

  alias Kendrick.{
    Repo,
    Scheduler,
    Slack,
    Task,
    Users,
    Workspaces
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
      job_name: schedule_job().name
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
    Scheduler.create_job(%{
      schedule: @schedule,
      task: {__MODULE__, :perform, [self()]}
    })
  end

  defp do_perform(project) do
    %{project: project}
    |> delete_completed_tasks()
    |> get_workspace()
    |> get_users()
    |> update_reports()
  end

  defp delete_completed_tasks(%{project: project} = data) do
    tasks =
      from(t in Task,
        join: u in assoc(t, :user),
        join: p in assoc(u, :projects),
        where: t.finished_status_set_at < p.report_saved_at,
        where: p.id == ^project.id
      )

    Repo.delete_all(tasks)

    data
  end

  defp get_workspace(%{project: project} = data) do
    workspace = Workspaces.for_project(project)

    Map.put(data, :workspace, workspace)
  end

  defp get_users(%{project: project} = data) do
    users =
      project
      |> Users.for_project()
      |> Users.all()

    Map.put(data, :users, users)
  end

  defp update_reports(%{users: users, workspace: workspace}) do
    Enum.each(users, fn user ->
      attachments = Slack.Report.build(user)

      Slack.Client.chat_update(%{
        attachments: attachments,
        channel: user.slack_channel,
        token: workspace.slack_token,
        ts: user.report_ts
      })
    end)
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
