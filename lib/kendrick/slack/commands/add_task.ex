defmodule Kendrick.Slack.Commands.AddTask do
  use GenServer

  alias Kendrick.{
    Repo,
    # Slack,
    Task,
    Users,
    Workspaces
  }

  @name :slack_commands_add_task_worker

  def start_link do
    GenServer.start_link(__MODULE__, [], name: @name)
  end

  def open_form(params) do
    GenServer.cast(@name, {:open_form, params})
  end

  def save_task(params) do
    GenServer.call(@name, {:save_task, params})
  end

  def init(args) do
    {:ok, args}
  end

  def handle_cast({:open_form, params}, state) do
    %{params: params}
    |> get_workspace()
    |> build_form()
    |> post_form()

    {:noreply, state}
  end

  def handle_call({:save_task, params}, _from, state) do
    result =
      %{params: params}
      |> get_user()
      |> validate_params()
      |> get_jira_data()
      |> do_save_task()

    {:reply, result, state}
  end

  defp get_workspace(%{params: params} = data) do
    workspace = Workspaces.get_by(team_id: params["team"]["id"])

    Map.put(data, :workspace, workspace)
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
        }
      ]
    }

    Map.put(data, :dialog, dialog)
  end

  defp post_form(%{dialog: dialog, params: %{"trigger_id" => trigger_id}, workspace: workspace}) do
    Kendrick.Slack.Client.dialog_open(dialog, trigger_id, workspace.slack_token)
  end

  defp get_user(%{params: params} = data) do
    user = Users.get_by(slack_id: params["user"]["id"])

    Map.put(data, :user, user)
  end

  defp validate_params(%{params: %{"submission" => %{"url" => nil, "description" => nil}}} = data) do
    errors =
      Poison.encode!(%{
        errors: [
          %{
            name: "url",
            error: "Please fill one of these fields"
          },
          %{
            name: "description",
            error: "Please fill one of these fields"
          }
        ]
      })

    Map.put(data, :errors, errors)
  end

  defp validate_params(data), do: data

  defp get_jira_data(%{errors: _errors} = data), do: data

  defp get_jira_data(%{params: %{"submission" => %{"url" => url}}} = data) when not is_nil(url) do
    jira_data =
      url
      |> String.trim()
      |> Kendrick.Jira.Task.key_from_url()
      |> Jira.API.ticket_details()

    Map.put(data, :jira_data, jira_data)
  end

  defp get_jira_data(data), do: data

  defp do_save_task(%{errors: errors}), do: {:error, errors}

  defp do_save_task(%{jira_data: %{"errors" => _errors}, params: %{"submission" => %{"description" => nil}}}) do
    errors =
      Poison.encode!(%{
        errors: [
          %{
            name: "url",
            error: "Invalid link"
          }
        ]
      })

    {:error, errors}
  end

  defp do_save_task(%{user: user} = data) do
    %Task{}
    |> Task.changeset(task_attributes(data))
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert!()

    :ok
  end

  defp task_attributes(%{jira_data: jira_data, params: params}) do
    jira_data
    |> Kendrick.Jira.Task.to_map()
    |> assign_url(params)
    |> assign_title(params)
  end

  defp task_attributes(%{params: params}), do: assign_title(%{}, params)

  defp assign_url(attributes, %{"submission" => %{"url" => nil}}), do: attributes

  defp assign_url(attributes, %{"submission" => %{"url" => url}}), do: Map.put(attributes, :url, url)

  defp assign_title(attributes, %{"submission" => %{"description" => nil}}), do: attributes

  defp assign_title(attributes, %{"submission" => %{"description" => title}}),
    do: Map.put(attributes, :title, title)

  # defp get_jira_task_details(%{params: params} = data) do
  #   task_text = String.trim(params["text"])
  #   jira_data = Jira.API.ticket_details(task_text)
  #
  #   data
  #   |> Map.put(:task_text, task_text)
  #   |> Map.put(:jira_data, jira_data)
  # end
  #
  # defp save_task(%{jira_data: jira_data} = data) do
  #   case Map.has_key?(jira_data, "errors") do
  #     true -> save_regular_task(data)
  #     false -> save_jira_task(data)
  #   end
  # end
  #
  # defp save_regular_task(%{task_text: task_text, user: user} = data) do
  #   task =
  #     %Task{}
  #     |> Task.changeset(%{title: task_text})
  #     |> Ecto.Changeset.put_assoc(:user, user)
  #     |> Repo.insert!()
  #
  #   Map.put(data, :task, task)
  # end
  #
  # defp save_jira_task(%{jira_data: jira_data, user: user} = data) do
  #   task =
  #     %Task{}
  #     |> Task.changeset(Kendrick.Jira.Task.to_map(jira_data))
  #     |> Ecto.Changeset.put_assoc(:user, user)
  #     |> Repo.insert!()
  #
  #   Map.put(data, :task, task)
  # end
  #
  # defp post_message(%{task: task, user: user, workspace: workspace}) do
  #   %{
  #     status: task.status,
  #     url: task.url,
  #     title: task.title
  #   }
  #   |> Poison.encode!()
  #   |> Slack.Client.post_message(user.slack_channel, workspace.slack_token)
  # end
end
