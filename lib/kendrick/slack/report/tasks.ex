defmodule Kendrick.Slack.Report.Tasks do
  import Kendrick.Slack.Shared, only: [encode_callback_id: 1]
  import Kendrick.Slack.Report.Shared, only: [set_status_action: 0]

  alias Kendrick.Task

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
      actions: actions(task, opts),
      callback_id: callback_id(task),
      color: Task.color(task),
      fallback: title(task, index),
      footer: footer(task),
      text: text(task),
      title: title(task, index)
    }
  end

  defp actions(%{disabled: true}, _opts) do
    [
      enable_action(),
      delete_action()
    ]
  end

  defp actions(%{id: task_id}, %{more_actions: id}) when task_id == id do
    [
      set_status_action(),
      edit_action(),
      disable_action(),
      delete_action()
    ]
  end

  defp actions(_task, _opts) do
    [
      set_status_action(),
      edit_action(),
      more_action()
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

  defp enable_action do
    %{
      name: "task_enable",
      text: "Enable",
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

  defp callback_id(task), do: encode_callback_id(%{id: task.id})

  defp title(%{disabled: true} = task, index), do: "#{index}. #{task.title}"
  defp title(task, index), do: "#{index}. #{task.title}"

  defp footer(%{disabled: true}), do: "This task won't appear in the project report."
  defp footer(_task), do: ""

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
