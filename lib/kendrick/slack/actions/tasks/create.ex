defmodule Kendrick.Slack.Actions.Tasks.Create do
  use GenServer

  import OK, only: [~>>: 2]
  import Kendrick.Slack.Shared, only: [find_user: 1, find_workspace: 1]

  alias Kendrick.{
    Repo,
    Slack,
    Task
  }

  alias Slack.{
    Actions,
    Report
  }

  @name :slack_actions_tasks_create_worker

  def start_link do
    GenServer.start_link(__MODULE__, [], name: @name)
  end

  def call(params) do
    GenServer.call(@name, {:call, params})
  end

  def init(args) do
    {:ok, args}
  end

  def handle_call({:call, params}, _from, state) do
    result =
      %{params: params}
      |> validate_params()
      ~>> find_workspace()
      ~>> find_user()
      ~>> get_jira_data()
      ~>> create_task()
      ~>> post_report()

    {:reply, result, state}
  end

  defp validate_params(%{params: %{"submission" => %{"url" => nil, "description" => nil}}}) do
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

    {:error, errors}
  end

  defp validate_params(data), do: {:ok, data}

  defp get_jira_data(%{params: %{"submission" => %{"url" => url}}} = data) when not is_nil(url) do
    jira_data =
      url
      |> String.trim()
      |> Kendrick.Jira.Task.key_from_url()
      |> Jira.API.ticket_details()

    {:ok, Map.put(data, :jira_data, jira_data)}
  end

  defp get_jira_data(data), do: {:ok, data}

  defp create_task(%{jira_data: %{"errors" => _errors}, params: %{"submission" => %{"description" => nil}}}) do
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

  defp create_task(%{user: user} = data) do
    task =
      %Task{}
      |> Task.changeset(task_attributes(data))
      |> Ecto.Changeset.put_assoc(:user, user)
      |> Ecto.Changeset.cast_assoc(:user, required: true)
      |> Repo.insert!()

    {:ok, Map.put(data, :task, task)}
  end

  defp task_attributes(%{jira_data: jira_data, params: params}) do
    jira_data
    |> Kendrick.Jira.Task.to_map()
    |> assign_url(params)
    |> assign_title(params)
    |> assign_status(params)
  end

  defp task_attributes(%{params: params}) do
    %{}
    |> assign_title(params)
    |> assign_status(params)
  end

  defp assign_url(attributes, %{"submission" => %{"url" => nil}}), do: attributes

  defp assign_url(attributes, %{"submission" => %{"url" => url}}), do: Map.put(attributes, :url, url)

  defp assign_title(attributes, %{"submission" => %{"description" => nil}}), do: attributes

  defp assign_title(attributes, %{"submission" => %{"description" => title}}) do
    Map.put(attributes, :title, title)
  end

  defp assign_status(attributes, %{"submission" => %{"status" => nil}}), do: attributes

  defp assign_status(attributes, %{"submission" => %{"status" => status}}) do
    Map.put(attributes, :status, status)
  end

  defp post_report(%{user: user, workspace: workspace} = data) do
    Slack.Client.respond(%{
      attachments: Report.build(user),
      token: workspace.slack_token,
      url: Actions.Tasks.ShowNewForm.get_response_url(user.slack_id)
    })

    {:ok, data}
  end
end
