defmodule Kendrick.Slack.Events.LinkShared.Atlassian do
  import OK, only: [~>>: 2]
  import Kendrick.Slack.Shared, only: [find_workspace: 1]

  alias Kendrick.{
    Jira,
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
    with uri_info <- URI.parse(url),
         query when not is_nil(query) <- Map.get(uri_info, :query),
         %{"focusedCommentId" => comment_id} <- URI.decode_query(query) do
      build_comment_unfurl(uri_info, comment_id)
    else
      nil ->
        uri_info = URI.parse(url)
        build_task_unfurl(uri_info)

      _ ->
        %{}
    end
  end

  defp build_task_unfurl(uri_info) do
    jira_task =
      uri_info
      |> Map.get(:path)
      |> jira_ticket_details()

    task_details =
      [
        "*Status:* #{jira_task.status}",
        "*Story points:* #{jira_task.points || "N/A"}",
        "*Assignee:* #{jira_task.assignee || "N/A"}"
      ]
      |> Enum.join(" | ")

    %{
      text: """
      *#{jira_task.title}*
      #{task_details}
      """,
      color: Task.color(jira_task)
    }
  end

  defp build_comment_unfurl(uri_info, comment_id) do
    comment =
      uri_info
      |> Map.get(:path)
      |> jira_ticket_details()
      |> Jira.Task.find_comment(comment_id)

    %{
      author_name: comment.author,
      text: comment.text
    }
  end

  defp jira_ticket_details(url) do
    url
    |> String.trim()
    |> Jira.Task.key_from_url()
    |> Jira.API.ticket_details()
    |> Jira.Task.to_map()
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
