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
        "name" => "add_task",
        "text" => "Add task",
        "type" => "button",
        "value" => "add_task"
      }
    ]
  end
end
