defmodule Kendrick.Slack.Actions.Tasks.Shared do
  alias Kendrick.Tasks

  def find_task(%{callback_id: %{"id" => task_id}} = data) do
    task = Tasks.get(task_id)

    {:ok, Map.put(data, :task, task)}
  end

  def validate_params(%{params: %{"submission" => %{"url" => nil, "description" => nil}}}) do
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

  def validate_params(data), do: {:ok, data}

  def get_jira_data(%{params: %{"submission" => %{"url" => url}}} = data) when not is_nil(url) do
    jira_data =
      url
      |> String.trim()
      |> Kendrick.Jira.Task.key_from_url()
      |> Jira.API.ticket_details()

    {:ok, Map.put(data, :jira_data, jira_data)}
  end

  def get_jira_data(data), do: {:ok, data}

  def ensure_task_url_valid(%{
        jira_data: %{"errors" => _errors},
        params: %{"submission" => %{"description" => nil}}
      }) do
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

  def ensure_task_url_valid(data), do: {:ok, data}

  def task_attributes(%{jira_data: jira_data, params: params}) do
    jira_data
    |> Kendrick.Jira.Task.to_map()
    |> assign_attributes(params)
  end

  def task_attributes(%{params: params}), do: assign_attributes(%{}, params)

  defp assign_attributes(data, params) do
    data
    |> assign_url(params)
    |> assign_title(params)
    |> assign_status(params)
  end

  defp assign_url(attributes, %{"submission" => %{"url" => url}}), do: Map.put(attributes, :url, url)

  defp assign_title(attributes, %{"submission" => %{"description" => nil}}), do: attributes

  defp assign_title(attributes, %{"submission" => %{"description" => title}}) do
    Map.put(attributes, :title, title)
  end

  defp assign_status(attributes, %{"submission" => %{"status" => nil}}),
    do: Map.put(attributes, :custom_status, false)

  defp assign_status(attributes, %{"submission" => %{"status" => status}}),
    do: Map.merge(attributes, %{status: status, custom_status: true})
end
