defmodule Kendrick.Slack.ProjectReport.SaveMessage do
  import Kendrick.Slack.Shared, only: [encode_callback_id: 1]

  @message "The report is saved!"

  def build(project) do
    %{
      actions: actions(),
      callback_id: callback_id(project),
      color: "#63BA3C",
      text: @message
    }
  end

  defp actions do
    [
      slack_post_action(),
      basecamp_post_action()
    ]
  end

  defp slack_post_action do
    %{
      name: "project_report_slack_post",
      text: "Slack post",
      type: "button"
    }
  end

  defp basecamp_post_action do
    %{
      name: "project_report_basecamp_post",
      text: "Basecamp post",
      type: "button"
    }
  end

  defp callback_id(project), do: encode_callback_id(%{project_id: project.id})
end
