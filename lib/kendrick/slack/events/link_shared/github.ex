defmodule Kendrick.Slack.Events.LinkShared.Github do
  import OK, only: [~>>: 2]
  import Kendrick.Slack.Shared, only: [find_workspace: 1]

  alias Kendrick.{
    Github,
    Repo,
    Slack,
    Users
  }

  @pull_request_regex ~r[github\.com/(.+)/(.+)/pull/(\d+)/?(files|commits)?$]

  def call(data) do
    data
    |> find_workspace()
    ~>> save_links()
    ~>> build_unfurls()
    ~>> post_unfurls()
  end

  defp save_links(%{links: links, params: params} = data) do
    %{
      "event" => %{
        "channel" => channel,
        "message_ts" => message_ts
      }
    } = params

    Enum.each(links, fn link ->
      %Slack.SharedLink{}
      |> Slack.SharedLink.changeset(%{channel: channel, ts: message_ts, url: link["url"]})
      |> Repo.insert!()
    end)

    {:ok, data}
  end

  defp build_unfurls(%{links: links} = data) do
    unfurls =
      Enum.reduce(links, %{}, fn %{"url" => url}, acc ->
        Map.put(acc, url, build_unfurl(url))
      end)

    {:ok, Map.put(data, :unfurls, unfurls)}
  end

  defp build_unfurl(url) do
    case Regex.run(@pull_request_regex, url) do
      [_, owner, repo, id | _] ->
        pull_request =
          %{owner: owner, repo: repo, id: id}
          |> Github.Client.pull_request()
          |> Github.PullRequest.parse()

        %{
          author_name: pull_request.author,
          color: pull_request.color,
          text: """
          *#{pull_request.title}*
          *Diff:* :heavy_plus_sign:#{pull_request.additions} */* :heavy_minus_sign:#{pull_request.deletions}
          """
        }

      _ ->
        %{}
    end
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
