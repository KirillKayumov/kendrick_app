defmodule Kendrick.Slack.Actions.Tasks.ShowNewForm do
  use GenServer

  import OK, only: [~>>: 2]
  import Kendrick.Slack.Shared, only: [find_workspace: 1, decode_callback_id: 1, encode_callback_id: 1]

  alias Kendrick.Slack

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
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
      ~>> build_form()
      ~>> show_form()
      ~>> save_response_url()

    {:noreply, new_state}
  end

  defp build_form(data) do
    dialog = %{
      callback_id: callback_id(data),
      title: "Add task",
      submit_label: "Save",
      elements: [
        %{
          label: "Link to task",
          name: "url",
          optional: true,
          placeholder: "https://aclgrc.atlassian.net/browse/PD-7200",
          subtype: "url",
          type: "text",
          value: "https://aclgrc.atlassian.net/browse/"
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

  defp callback_id(%{callback_id: callback_id}) do
    callback_id
    |> Map.put(:action, "task_add")
    |> encode_callback_id()
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
