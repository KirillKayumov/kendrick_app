defmodule Kendrick.Slack.Commands.Report.Tasks do
  alias Kendrick.{
    Jira,
    Tasks
  }

  def build(user) do
    []
    |> add_title()
    |> add_tasks(user)
    |> add_menu()
  end

  defp add_title(attachments) do
    attachments ++
      [
        %{
          title: "TASKS",
          fallback: "TASKS"
        }
      ]
  end

  defp add_tasks(attachments, user) do
    tasks =
      user
      |> Tasks.for_user()
      |> Enum.with_index(1)
      |> Enum.map(fn {task, index} ->
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
          actions: task_actions(task)
        }
      end)

    attachments ++ tasks
  end

  defp task_title(task, index) do
    ["#{index}.", Jira.Task.key_from_url(task.url), task.title]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  defp task_actions(task) do
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

  defp add_menu(attachments) do
    attachments ++ [menu()]
  end

  defp menu do
    %{
      "actions" => menu_actions(),
      "callback_id" => "menu",
      "color" => "#717171",
      "fallback" => "Menu",
      "title" => "MENU"
    }
  end

  defp menu_actions do
    [
      %{
        "name" => "add_task",
        "text" => "Add task",
        "type" => "button",
        "value" => "add_task"
      }
    ]
  end
end
