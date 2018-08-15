defmodule Kendrick.Slack.ProjectReport.Menu do
  import Kendrick.Slack.Shared, only: [encode_callback_id: 1]

  def build(project) do
    %{
      actions: actions(),
      callback_id: callback_id(project),
      color: "#717171",
      fallback: "Menu",
      title: "MENU"
    }
  end

  defp actions do
    [
      save_report_action()
    ]
  end

  defp save_report_action do
    %{
      name: "project_report_save",
      text: "Save report",
      type: "button"
    }
  end

  defp callback_id(project), do: encode_callback_id(%{project_id: project.id})
end
