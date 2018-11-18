defmodule Kendrick.Jira.Task do
  def to_map(jira_data) do
    %{
      assignee: assignee(jira_data),
      points: points(jira_data),
      status: status(jira_data),
      title: title(jira_data),
      type: type(jira_data),
      url: url(jira_data)
    }
  end

  def key_from_url(nil), do: nil

  def key_from_url(url) do
    url
    |> String.split("/")
    |> List.last()
  end

  defp assignee(%{"fields" => %{"assignee" => %{"displayName" => assignee}}}), do: assignee
  defp assignee(_), do: nil

  defp points(%{"fields" => %{"customfield_10004" => points}}), do: trunc(points)
  defp points(_), do: nil

  defp status(%{"fields" => %{"status" => %{"name" => status}}}), do: status
  defp status(_), do: nil

  defp title(%{"fields" => %{"summary" => title}}), do: title
  defp title(_), do: nil

  defp type(%{"fields" => %{"issuetype" => %{"name" => type}}}), do: type
  defp type(_), do: nil

  defp url(%{"key" => key}), do: "#{Application.fetch_env!(:jira, :host)}/browse/#{key}"
  defp url(_), do: nil
end
