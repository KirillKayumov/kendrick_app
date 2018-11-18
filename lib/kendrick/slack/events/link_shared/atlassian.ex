defmodule Kendrick.Slack.Events.LinkShared.Atlassian do
  import OK, only: [~>>: 2]
  import Kendrick.Slack.Shared, only: [find_workspace: 1]

  alias Kendrick.{
    Slack,
    Task,
    Users
  }

  def call(data) do
    data
    |> find_workspace()
    ~>> build_unfurls()
    ~>> post_unfurls()
  end

  defp build_unfurls(%{links: links} = data) do
    unfurls =
      Enum.reduce(links, %{}, fn %{"url" => url}, acc ->
        Map.put(acc, url, build_unfurl(url))
      end)

    {:ok, Map.put(data, :unfurls, unfurls)}
  end

  defp build_unfurl(url) do
    jira_task =
      url
      |> jira_ticket_details()
      |> Kendrick.Jira.Task.to_map()

    %{
      text: """
      *#{jira_task.title}*
      *Status:* #{jira_task.status}
      *Story points:* #{jira_task.points}
      *Assignee:* #{jira_task.assignee}
      """,
      color: Task.color(jira_task)
    }
  end

  defp jira_ticket_details(url) do
    url
    |> String.trim()
    |> Kendrick.Jira.Task.key_from_url()
    |> Jira.API.ticket_details()
  end

  defp post_unfurls(%{unfurls: unfurls, workspace: workspace, params: params}) do
    %{
      "event" => %{
        "channel" => channel,
        "message_ts" => message_ts
      }
    } = params

    token = Users.first_with_slack_token(workspace).slack_token

    Slack.Client.chat_unfurl(%{
      token: token,
      channel: channel,
      ts: message_ts,
      unfurls: unfurls
    })
  end
end
