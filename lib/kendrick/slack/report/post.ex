defmodule Kendrick.Slack.Report.Post do
  alias Kendrick.{
    Repo,
    Slack,
    User
  }

  def call(user, workspace) do
    %{user: user, workspace: workspace}
    |> build()
    |> post()
    |> save_report_ts()
  end

  defp build(%{user: user} = data) do
    attachments = Slack.Report.build(user)

    Map.put(data, :attachments, attachments)
  end

  defp post(%{attachments: attachments, user: user, workspace: workspace} = data) do
    response = Slack.Client.post_message(attachments, user.slack_channel, workspace.slack_token)

    Map.put(data, :report_ts, response["ts"])
  end

  defp save_report_ts(%{user: user, report_ts: report_ts}) do
    user
    |> User.changeset(%{report_ts: report_ts})
    |> Repo.update!()
  end
end
