defmodule Kendrick.Slack.Report.Tasks do
  import Kendrick.Slack.Shared, only: [encode_callback_id: 1]

  def build(tasks, opts \\ %{}) do
    case length(tasks) do
      0 ->
        help()

      _ ->
        tasks
        |> Enum.with_index(1)
        |> Enum.map(&task(&1, opts))
    end
  end

  defp help do
    [
      %{
        text: "No tasks."
      }
    ]
  end

  defp task({task, index}, opts) do
    %{
      actions: task_actions(task, opts),
      callback_id: callback_id(task, opts),
      color: color(task),
      fallback: task_title(task, index),
      text: task_text(task),
      title: task_title(task, index)
    }
  end

  defp task_actions(%{id: todo_id}, %{more_actions: id}) when todo_id == id do
    [
      set_status_action(),
      edit_action(),
      delete_action()
    ]
  end

  defp task_actions(_task, %{project: _project}) do
    [
      edit_action(),
      delete_action()
    ]
  end

  defp task_actions(_task, _opts) do
    [
      set_status_action(),
      more_action()
    ]
  end

  defp set_status_action do
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
        }
      ]
    }
  end

  defp edit_action do
    %{
      name: "task_edit",
      text: "Edit",
      type: "button"
    }
  end

  defp more_action do
    %{
      name: "task_more",
      text: "More...",
      type: "button"
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

  defp callback_id(task, opts) do
    %{id: task.id}
    |> add_project_id(opts)
    |> encode_callback_id()
  end

  defp add_project_id(data, %{project: project}), do: Map.put(data, :project_id, project.id)
  defp add_project_id(data, _opts), do: data

  defp color(task) do
    case task.type do
      "Bug" -> "#E5493A"
      "Design" -> "#FF9C23"
      "Epic" -> "#904EE2"
      "Fail Test" -> "#8095AA"
      "Story" -> "#63BA3C"
      "Sub-task" -> "#4BAEE8"
      "Task" -> "#4BADE8"
      _ -> ""
    end
  end

  defp task_title(task, index), do: "#{index}. #{task.title}"

  defp task_text(task) do
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
