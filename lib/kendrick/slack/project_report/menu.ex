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
      project_report_post_action()
    ]
  end

  defp project_report_post_action do
    %{
      name: "project_report_post",
      text: "Create post",
      type: "button"
    }
  end

  defp callback_id(project), do: encode_callback_id(%{project_id: project.id})
end
