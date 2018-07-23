defmodule Kendrick.Slack.Report.Menu do
  import Kendrick.Slack.Shared, only: [encode_callback_id: 1]

  def build(user, opts \\ %{})

  def build(user, %{project: _project} = opts) do
    %{
      "actions" => menu_actions(opts),
      "callback_id" => callback_id(user, opts),
      "fallback" => "Menu"
    }
  end

  def build(user, opts) do
    %{
      "actions" => menu_actions(opts),
      "callback_id" => callback_id(user, opts),
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

  defp callback_id(user, %{project: project}), do: encode_callback_id(%{user_id: user.id, project_id: project.id})

  defp callback_id(user, _opts), do: encode_callback_id(%{user_id: user.id})
end
