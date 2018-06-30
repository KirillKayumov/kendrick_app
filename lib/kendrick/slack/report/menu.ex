defmodule Kendrick.Slack.Report.Menu do
  def build do
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
        "name" => "task_add",
        "text" => "Add task",
        "type" => "button"
      }
    ]
  end
end
