defmodule Kendrick.Slack.Report.Tasks do
  alias Kendrick.Jira

  def build(user) do
    user
    |> Kendrick.Tasks.for_user()
    |> Enum.with_index(1)
    |> Enum.map(&(task(&1)))
  end

  defp task({task, index}) do
    %{
      title: task_title(task, index),
      title_link: task.url,
      fallback: task_title(task, index),
      callback_id: task.id,
      fields: [
        %{
          title: "Status",
          value: task.status
        }
      ],
      actions: task_actions()
    }
  end

  defp task_title(task, index) do
    ["#{index}.", Jira.Task.key_from_url(task.url), task.title]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  defp task_actions() do
    [
      %{
        name: "task_status",
        text: "Set status",
        type: "select",
        options: [
          %{
            text: "Starting Today",
            value: "Starting Today"
          },
          %{
            text: "WIP",
            value: "WIP"
          },
          %{
            text: "Code Review",
            value: "Code Review"
          },
          %{
            text: "Done",
            value: "Done"
          },
        ]
      }
    ]
  end
end
