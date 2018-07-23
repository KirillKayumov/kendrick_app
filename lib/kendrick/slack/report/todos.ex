defmodule Kendrick.Slack.Report.Todos do
  def build(user) do
    todos = Kendrick.Todos.for_user(user)

    case length(todos) do
      0 ->
        help()

      _ ->
        todos
        |> Enum.with_index(1)
        |> Enum.map(&todo(&1))
    end
  end

  defp help() do
    [
      %{
        text: "No todos.",
        footer: "To add a todo use the slash-command `/todo order a pizza`"
      }
    ]
  end

  defp todo({todo, index}) do
    %{
      actions: actions(todo),
      callback_id: todo.id,
      color: color(todo),
      text: text(todo, index)
    }
  end

  defp actions(%{done: false}) do
    [
      %{
        name: "todo_done",
        style: "primary",
        text: "Done",
        type: "button"
      },
      delete_action()
    ]
  end

  defp actions(%{done: true}), do: [delete_action()]

  defp delete_action do
    %{
      name: "todo_delete",
      text: "Delete",
      type: "button"
    }
  end

  defp color(%{done: false}), do: "#EABA51"
  defp color(%{done: true}), do: "#42996D"

  defp text(%{done: false, text: text}, index), do: "*#{index}. #{text}*"
  defp text(%{done: true, text: text}, index), do: "*~#{index}. #{text}~*"
end
