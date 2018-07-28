defmodule Kendrick.Slack.Actions.Users.UpdateAbsence do
  use GenServer

  import OK, only: [~>>: 2]

  import Kendrick.Slack.Shared,
    only: [find_workspace: 1, decode_callback_id: 1, user_from_callback_id: 1, find_project: 1]

  alias Kendrick.{
    Repo,
    Slack,
    User
  }

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def call(params) do
    GenServer.cast(__MODULE__, {:call, params})
  end

  def init(args) do
    {:ok, args}
  end

  def handle_cast({:call, params}, state) do
    %{params: params}
    |> decode_callback_id()
    ~>> find_workspace()
    ~>> find_project()
    ~>> update_absence()
    ~>> update_report()

    {:noreply, state}
  end

  defp update_absence(%{params: params} = data) do
    %{
      "actions" => [
        %{
          "selected_options" => [%{"value" => absence}]
        }
      ]
    } = params

    user = user_from_callback_id(data)
    new_absence = if absence == "reset", do: nil, else: absence

    user
    |> User.changeset(%{absence: new_absence})
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
end
