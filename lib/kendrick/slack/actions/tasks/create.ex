defmodule Kendrick.Slack.Actions.Tasks.Create do
  use GenServer

  import OK, only: [~>>: 2]

  import Kendrick.Slack.Shared,
    only: [find_user: 1, find_workspace: 1, find_project: 1, decode_callback_id: 1, user_from_callback_id: 1]

  import Kendrick.Slack.Actions.Tasks.Shared,
    only: [validate_params: 1, get_jira_data: 1, ensure_task_url_valid: 1, task_attributes: 1]

  alias Kendrick.{
    Repo,
    Slack,
    Task
  }

  alias Slack.{
    Actions,
    Report
  }

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def call(params) do
    GenServer.call(__MODULE__, {:call, params})
  end

  def init(args) do
    {:ok, args}
  end

  def handle_call({:call, params}, _from, state) do
    result =
      %{params: params}
      |> validate_params()
      ~>> get_jira_data()
      ~>> ensure_task_url_valid()
      ~>> decode_callback_id()
      ~>> find_workspace()
      ~>> find_user()
      ~>> find_project()
      ~>> create_task()
      ~>> update_report()

    {:reply, result, state}
  end

  defp create_task(data) do
    user = user_from_callback_id(data)

    task =
      %Task{}
      |> Task.changeset(task_attributes(data))
      |> Ecto.Changeset.put_assoc(:user, user)
      |> Ecto.Changeset.cast_assoc(:user, required: true)
      |> Repo.insert!()

    {:ok, Map.put(data, :task, task)}
  end

  defp update_report(%{user: user, project: project, workspace: workspace} = data) do
    Slack.Client.respond(%{
      attachments: Slack.ProjectReport.build(project),
      token: workspace.slack_token,
      url: Actions.Tasks.ShowNewForm.get_response_url(user.slack_id)
    })

    {:ok, data}
  end

  defp update_report(%{user: user, workspace: workspace} = data) do
    Slack.Client.respond(%{
      attachments: Report.build(user),
      token: workspace.slack_token,
      url: Actions.Tasks.ShowNewForm.get_response_url(user.slack_id)
    })

    {:ok, data}
  end
end
