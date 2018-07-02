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
      title: task_title(task, index),
      fallback: task_title(task, index),
      callback_id: encode_callback_id(%{
        id: task.id
      }),
      fields: fields(task),
      actions: task_actions(task, opts)
    }
  end

  defp task_title(task, index), do: "#{index}. #{task.title}"

  defp fields(task) do
    [
      task_link(task),
      task_status(task)
    ]
  end

  defp task_link(%{url: nil}), do: %{}

  defp task_link(%{url: url}) do
    %{
      title: "Link",
      value: url
    }
  end

  defp task_status(%{status: nil}), do: %{}

  defp task_status(%{status: status}) do
    %{
      title: "Status",
      value: status
    }
  end

  defp task_actions(%{id: todo_id}, %{more_actions: id}) when todo_id == id do
    [
      set_status_action(),
      edit_action(),
      delete_action()
    ]
  end

  defp task_actions(_task, %{project_report: true}) do
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
end
