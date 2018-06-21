defmodule Kendrick.Slack.Actions.Tasks.ShowNewForm do
  use GenServer

  import OK, only: [~>>: 2]
  import Kendrick.Slack.Shared, only: [find_workspace: 1]

  alias Kendrick.Slack

  @name :slack_actions_show_new_task_form_worker

  def start_link do
    GenServer.start_link(__MODULE__, [], name: @name)
  end

  def get_response_url(slack_id) do
    GenServer.call(@name, {:get_response_url, slack_id})
  end

  def call(params) do
    GenServer.cast(@name, {:call, params})
  end

  def init(_args) do
    {:ok, %{}}
  end

  def handle_call({:get_response_url, slack_id}, _from, state) do
    {:reply, state[slack_id], state}
  end

  def handle_cast({:call, params}, state) do
    new_state =
      %{params: params, state: state}
      |> find_workspace()
      ~>> build_form()
      ~>> show_form()
      ~>> save_response_url()

    {:noreply, new_state}
  end

  defp build_form(data) do
    dialog = %{
      callback_id: "add_task",
      title: "Add task",
      submit_label: "Add",
      elements: [
        %{
          label: "Link to task",
          name: "url",
          optional: true,
          placeholder: "https://aclgrc.atlassian.net/browse/PD-7200",
          subtype: "url",
          type: "text"
        },
        %{
          label: "Task description",
          name: "description",
          optional: true,
          placeholder: "Deploy to preprod",
          type: "text"
        },
        %{
          label: "Status",
          name: "status",
          optional: true,
          placeholder: "WIP",
          type: "text"
        }
      ]
    }

    {:ok, Map.put(data, :dialog, dialog)}
  end

  defp show_form(%{dialog: dialog, params: params, workspace: workspace} = data) do
    Slack.Client.dialog_open(
      dialog,
      params["trigger_id"],
      workspace.slack_token
    )

    {:ok, data}
  end

  defp save_response_url(%{state: state, params: params}) do
    Map.put(state, params["user"]["id"], params["response_url"])
  end
end
