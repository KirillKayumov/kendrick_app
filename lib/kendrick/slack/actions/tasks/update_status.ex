defmodule Kendrick.Slack.Actions.Tasks.UpdateStatus do
  use GenServer

  import OK, only: [~>>: 2]
  import Kendrick.Slack.Shared, only: [find_workspace: 1, find_user: 1, decode_callback_id: 1, find_project: 1]
  import Kendrick.Slack.Actions.Tasks.Shared, only: [find_task: 1, jira_ticket_details: 1]

  alias Kendrick.{
    Jira,
    Repo,
    Slack,
    Task
  }

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def call(params) do
    GenServer.cast(__MODULE__, {:call, params})
  end

  def init(args) do
    {:ok, args}
  end

  def handle_cast({:call, params}, state) do
    %{params: params}
    |> find_workspace()
    ~>> find_user()
    ~>> decode_callback_id()
    ~>> find_project()
    ~>> find_task()
    ~>> get_status()
    ~>> update_status()
    ~>> update_report()

    {:noreply, state}
  end

  defp get_status(%{params: params, task: task} = data) do
    {status, custom_status} =
      case get_status_from_params(params) do
        "-" ->
          status =
            task.url
            |> jira_ticket_details()
            |> Jira.Task.to_map()
            |> Map.get(:status)

          {status, false}

        status ->
          {status, true}
      end

    {:ok, Map.merge(data, %{status: status, custom_status: custom_status})}
  end

  defp get_status_from_params(params) do
    %{
      "actions" => [
        %{
          "selected_options" => [%{"value" => status}]
        }
      ]
    } = params

    status
  end

  defp update_status(%{task: task, status: status, custom_status: custom_status} = data) do
    task
    |> Task.changeset(%{status: status, custom_status: custom_status})
    |> Repo.update!()

    {:ok, data}
  end

  defp update_report(%{params: params, workspace: workspace, project: project}) do
    Slack.Client.respond(%{
      attachments: Slack.ProjectReport.build(project),
      token: workspace.slack_token,
      url: params["response_url"]
    })
  end

  defp update_report(%{params: params, workspace: workspace, user: user}) do
    Slack.Client.respond(%{
      attachments: Slack.Report.build(user),
      token: workspace.slack_token,
      url: params["response_url"]
    })
  end
end
