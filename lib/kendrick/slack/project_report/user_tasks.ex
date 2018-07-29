defmodule Kendrick.Slack.ProjectReport.UserTasks do
  import Kendrick.Slack.Shared, only: [encode_callback_id: 1]

  def build(user, project) do
    case length(user.tasks) do
      0 ->
        help(user)

      _ ->
        user.tasks
        |> Enum.with_index(1)
        |> Enum.map(&task(&1, user, project))
    end
  end

  defp help(user) do
    [
      %{
        color: user.color,
        text: "No tasks."
      }
    ]
  end

  defp task({task, index}, user, project) do
    %{
      actions: actions(),
      callback_id: callback_id(task, project),
      color: user.color,
      fallback: title(task, index),
      text: text(task),
      title: title(task, index)
    }
  end

  defp actions do
    [
      edit_action(),
      disable_action(),
      delete_action()
    ]
  end

  defp edit_action do
    %{
      name: "task_edit",
      text: "Edit",
      type: "button"
    }
  end

  defp disable_action do
    %{
      name: "task_disable",
      text: "Disable",
      type: "button",
      confirm: %{
        title: "Are you sure?",
        ok_text: "Yes",
        dismiss_text: "No"
      }
    }
  end

  defp delete_action do
    %{
      confirm: %{
        title: "Are you sure?",
        ok_text: "Yes",
        dismiss_text: "No"
      },
      name: "task_delete",
      style: "danger",
      text: "Delete",
      type: "button"
    }
  end

  defp callback_id(task, project) do
    encode_callback_id(%{
      id: task.id,
      project_id: project.id
    })
  end

  defp title(task, index), do: "#{index}. #{task.title}"

  defp text(task) do
    """
    #{task_link(task)}
    #{task_status(task)}
    """
  end

  defp task_link(%{url: nil}), do: ""

  defp task_link(%{url: url}), do: "*Link:* #{url}"

  defp task_status(%{status: nil}), do: ""

  defp task_status(%{status: status}), do: "*Status:* #{status}"
end
