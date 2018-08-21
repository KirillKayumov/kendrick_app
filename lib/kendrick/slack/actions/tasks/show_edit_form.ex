defmodule Kendrick.Slack.Actions.Tasks.ShowEditForm do
  use GenServer

  import OK, only: [~>>: 2]
  import Kendrick.Slack.Shared, only: [find_workspace: 1, decode_callback_id: 1]
  import Kendrick.Slack.Actions.Tasks.Shared, only: [find_task: 1]

  alias Kendrick.Slack

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def get_response_url(slack_id) do
    GenServer.call(__MODULE__, {:get_response_url, slack_id})
  end

  def call(params) do
    GenServer.cast(__MODULE__, {:call, params})
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
      |> decode_callback_id()
      ~>> find_workspace()
      ~>> find_task()
      ~>> build_form()
      ~>> show_form()
      ~>> save_response_url()

    {:noreply, new_state}
  end

  defp build_form(%{task: task, callback_id: callback_id} = data) do
    dialog = %{
      callback_id: Poison.encode!(Map.put(callback_id, :action, "task_edit")),
      title: "Edit task",
      submit_label: "Save",
      elements: [
        %{
          label: "Link to task",
          name: "url",
          optional: true,
          placeholder: "https://aclgrc.atlassian.net/browse/PD-7200",
          subtype: "url",
          type: "text",
          value: task.url
        },
        %{
          label: "Task description",
          name: "description",
          optional: true,
          placeholder: "Deploy to preprod",
          type: "text",
          value: task.title
        },
        %{
          label: "Status",
          name: "status",
          optional: true,
          placeholder: "WIP",
          type: "text",
          value: task.status
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
