defmodule Kendrick.Slack.Report.Post do
  alias Kendrick.{
    Repo,
    Slack,
    User
  }

  def call(data) do
    data
    |> post()
    |> save_report_ts()
  end

  defp post(%{report: report, user: user, workspace: workspace} = data) do
    response = Slack.Client.post_message(report, user.slack_channel, workspace.slack_token)

    Map.put(data, :report_ts, response["ts"])
  end

  defp save_report_ts(%{user: user, report_ts: report_ts}) do
    user
    |> User.changeset(%{report_ts: report_ts})
    |> Repo.update!()
  end
end
