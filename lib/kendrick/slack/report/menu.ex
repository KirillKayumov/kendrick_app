defmodule Kendrick.Slack.Report.Menu do
  def build(opts \\ %{})

  def build(%{project: _project} = opts) do
    %{
      "actions" => menu_actions(opts),
      "callback_id" => "menu",
      "fallback" => "Menu"
    }
  end

  def build(opts) do
    %{
      "actions" => menu_actions(opts),
      "callback_id" => "menu",
      "color" => "#717171",
      "fallback" => "Menu",
      "title" => "MENU"
    }
  end

  defp menu_actions(%{project: _project}) do
    [
      add_task_action()
    ]
  end

  defp menu_actions(_opts) do
    [
      add_task_action(),
      project_report_action()
    ]
  end

  defp add_task_action do
    %{
      "name" => "task_add",
      "text" => "Add task",
      "type" => "button"
    }
  end

  defp project_report_action do
    %{
      "name" => "project_report",
      "text" => "Project report",
      "type" => "button"
    }
  end
end
