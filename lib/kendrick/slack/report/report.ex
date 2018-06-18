defmodule Kendrick.Slack.Report do
  alias Kendrick.Slack.Report.{
    Menu,
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
    attachments ++ Tasks.build(user)
  end

  defp add_menu(attachments) do
    attachments ++ [Menu.build()]
  end
end
