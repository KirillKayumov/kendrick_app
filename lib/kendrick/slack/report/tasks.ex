defmodule Kendrick.Slack.Report.Tasks do
  alias Kendrick.Jira

  def build(user, opts) do
    user
    |> Kendrick.Tasks.for_user()
    |> Enum.with_index(1)
    |> Enum.map(&task(&1, opts))
  end

  defp task({task, index}, opts) do
    %{
      title: task_title(task, index),
      title_link: task.url,
      fallback: task_title(task, index),
      callback_id: "task:#{task.id}",
      fields: [
        %{
          title: "Status",
          value: task.status
        }
      ],
      actions: task_actions(task, opts)
    }
  end

  defp task_title(task, index) do
    ["#{index}.", Jira.Task.key_from_url(task.url), task.title]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  defp task_actions(%{id: todo_id}, %{more_actions: id}) when todo_id == id do
    [
      set_status_action(),
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

  def edit_action do
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
