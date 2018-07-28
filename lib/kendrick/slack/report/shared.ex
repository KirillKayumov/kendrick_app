defmodule Kendrick.Slack.Report.Shared do
  @absence_reasons %{
    "day_off" => "Day off",
    "sick_leave" => "Sick leave",
    "vacation" => "Vacation"
  }

  def absence_reasons, do: @absence_reasons
end
