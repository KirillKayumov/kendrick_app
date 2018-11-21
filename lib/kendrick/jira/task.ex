defmodule Kendrick.Jira.Task do
  alias Kendrick.Jira

  def to_map(jira_data) do
    %{
      assignee: assignee(jira_data),
      comments: comments(jira_data),
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

  def find_comment(%{comments: comments}, id) when is_list(comments), do: Enum.find(comments, &(&1.id == id))
  def find_comment(_, _), do: nil

  defp assignee(%{"fields" => %{"assignee" => %{"displayName" => assignee}}}), do: assignee
  defp assignee(_), do: nil

  defp points(%{"fields" => %{"customfield_10004" => points}}) when is_number(points), do: trunc(points)
  defp points(_), do: nil

  defp status(%{"fields" => %{"status" => %{"name" => status}}}), do: status
  defp status(_), do: nil

  defp title(%{"fields" => %{"summary" => title}}), do: title
  defp title(_), do: nil

  defp type(%{"fields" => %{"issuetype" => %{"name" => type}}}), do: type
  defp type(_), do: nil

  defp url(%{"key" => key}), do: "#{host()}/browse/#{key}"
  defp url(_), do: nil

  defp host, do: Application.fetch_env!(:kendrick, Jira.API)[:host]

  defp comments(%{"fields" => %{"comment" => %{"comments" => comments}}}) do
    Enum.map(comments, &Jira.Comment.to_map/1)
  end

  defp comments(_), do: nil
end
