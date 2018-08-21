defmodule Kendrick.Slack.Actions.Tasks.Disable do
  use GenServer

  import OK, only: [~>>: 2]
  import Kendrick.Slack.Shared, only: [find_workspace: 1, find_user: 1, find_project: 1, decode_callback_id: 1]
  import Kendrick.Slack.Actions.Tasks.Shared, only: [find_task: 1]

  alias Kendrick.{
    Repo,
    Slack,
    Task
  }

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def disable(params) do
    GenServer.cast(__MODULE__, {:call, true, params})
  end

  def enable(params) do
    GenServer.cast(__MODULE__, {:call, false, params})
  end

  def init(args) do
    {:ok, args}
  end

  def handle_cast({:call, disabled, params}, state) do
    %{params: params}
    |> decode_callback_id()
    ~>> find_workspace()
    ~>> find_project()
    ~>> find_user()
    ~>> find_task()
    ~>> disable(disabled)
    ~>> update_report()

    {:noreply, state}
  end

  defp disable(%{task: task} = data, disabled) do
    task
    |> Task.changeset(%{disabled: disabled})
    |> Repo.update!()

    {:ok, data}
  end

  defp update_report(%{project: project, params: params, workspace: workspace}) do
    Slack.Client.respond(%{
      attachments: Slack.ProjectReport.build(project),
      token: workspace.slack_token,
      url: params["response_url"]
    })
  end

  defp update_report(%{user: user, params: params, workspace: workspace}) do
    Slack.Client.respond(%{
      attachments: Slack.Report.build(user),
      token: workspace.slack_token,
      url: params["response_url"]
    })
  end
end
