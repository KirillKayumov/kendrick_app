defmodule Kendrick.Slack.Commands.Reward do
  use GenServer

  alias Kendrick.{
    # Repo,
    Slack,
    # Task,
    Users,
    Workspaces
  }

  @name :slack_commands_reward_worker

  def start_link do
    GenServer.start_link(__MODULE__, [], name: @name)
  end

  def show_form(params) do
    GenServer.cast(@name, {:show_form, params})
  end

  def init(args) do
    {:ok, args}
  end

  def handle_cast({:show_form, params}, state) do
    %{params: params}
    |> get_workspace()
    |> get_user()
    |> build_form()
    |> get_reward_posibilities()
    |> post_form()

    {:noreply, state}
  end

  defp get_workspace(%{params: %{"team_id" => team_id}} = data) do
    workspace = Workspaces.get_by(team_id: team_id)

    Map.put(data, :workspace, workspace)
  end

  defp get_user(%{params: %{"user_id" => slack_id}} = data) do
    user = Users.get_by(slack_id: slack_id)

    Map.put(data, :user, user)
  end

  defp get_reward_posibilities(%{user: %{rewards_token: rewards_token}} = data) do
    require IEx
    IEx.pry()

    data
  end

  defp build_form(data) do
    dialog = %{
      callback_id: "reward",
      title: "Give reward",
      submit_label: "Give",
      elements: [
        %{
          label: "Receivers",
          name: "receivers",
          type: "select",
          options: [
            %{
              label: "Hindu (Indian) vegetarian",
              value: "hindu"
            },
            %{
              label: "Strict vegan",
              value: "vegan"
            },
            %{
              label: "Kosher",
              value: "kosher"
            },
            %{
              label: "Just put it in a burrito",
              value: "burrito"
            }
          ]
        }
      ]
    }

    Map.put(data, :dialog, dialog)
  end

  defp post_form(%{dialog: dialog, params: %{"trigger_id" => trigger_id}, workspace: workspace}) do
    Slack.Client.dialog_open(dialog, trigger_id, workspace.slack_token)
  end
end
