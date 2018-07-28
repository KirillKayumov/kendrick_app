defmodule Kendrick.Slack.Report.Menu do
  import Kendrick.Slack.Shared, only: [encode_callback_id: 1]
  import Kendrick.Slack.Report.Shared, only: [absence_reasons: 0]

  def build(user, opts \\ %{})

  def build(user, %{project: _project} = opts) do
    %{
      actions: menu_actions(opts),
      callback_id: callback_id(user, opts),
      fallback: "Menu"
    }
  end

  def build(user, opts) do
    %{
      actions: menu_actions(opts),
      callback_id: callback_id(user, opts),
      color: "#717171",
      fallback: "Menu",
      title: "MENU"
    }
  end

  def menu_actions(%{project: _project}) do
    [
      add_task_action(),
      set_absence_action()
    ]
  end

  def menu_actions(_opts) do
    [
      add_task_action(),
      project_report_action()
    ]
  end

  defp add_task_action do
    %{
      name: "task_add",
      text: "Add task",
      type: "button"
    }
  end

  defp set_absence_action do
    %{
      name: "user_update_absence",
      text: "Absence reason",
      type: "select",
      options: [
        %{
          text: absence_reasons()["day_off"],
          value: "day_off"
        },
        %{
          text: absence_reasons()["sick_leave"],
          value: "sick_leave"
        },
        %{
          text: absence_reasons()["vacation"],
          value: "vacation"
        },
        %{
          text: "Reset",
          value: "reset"
        }
      ]
    }
  end

  defp project_report_action do
    %{
      name: "project_report",
      text: "Project report",
      type: "button"
    }
  end

  defp callback_id(user, %{project: project}), do: encode_callback_id(%{user_id: user.id, project_id: project.id})

  defp callback_id(user, _opts), do: encode_callback_id(%{user_id: user.id})
end
