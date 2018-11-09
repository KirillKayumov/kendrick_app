defmodule Kendrick.Slack.Report do
  alias Kendrick.Slack.Report.{
    Menu,
    Tasks,
    Todos
  }

  def build(user, opts \\ %{}) do
    []
    |> add_tasks_title(opts)
    |> add_task_list(user, opts)
    |> add_todo_title()
    |> add_todo_list(user)
    |> add_menu(user)
  end

  defp add_tasks_title(attachments, opts) do
    attachments ++
      [
        %{
          color: "#717171",
          fallback: opts[:title] || "Find your tasks and todos below.",
          title: "TASKS"
        }
      ]
  end

  defp add_task_list(attachments, user, opts) do
    tasks = Kendrick.Tasks.for_user(user)

    attachments ++ Tasks.build(tasks, opts)
  end

  defp add_menu(attachments, user), do: attachments ++ [Menu.build(user)]

  defp add_todo_title(attachments) do
    attachments ++
      [
        %{
          color: "#717171",
          fallback: "TODO",
          title: "TODO"
        }
      ]
  end

  defp add_todo_list(attachments, user), do: attachments ++ Todos.build(user)
end
