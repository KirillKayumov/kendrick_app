defmodule Kendrick.Slack.Report.Todos do
  def build(user) do
    user
    |> Kendrick.Todos.for_user()
    |> Enum.with_index(1)
    |> Enum.map(&todo(&1))
  end

  defp todo({todo, index}) do
    %{
      text: todo_title(todo, index),
      callback_id: todo.id,
      actions: []
    }
  end

  defp todo_title(todo, index), do: "~#{index}. #{todo.text}~"

  defp todo_actions do
    [
      %{
        name: "todo_status",
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
    ]
  end
end
