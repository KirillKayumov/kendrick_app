defmodule Kendrick.Slack.Report.Shared do
  @absence_reasons %{
    "day_off" => "Day off",
    "sick_leave" => "Sick leave",
    "vacation" => "Vacation"
  }

  def absence_reasons, do: @absence_reasons

  def set_status_action do
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
end
