defmodule Kendrick.Jira.Task do
  def to_map(jira_data) do
    %{
      status: status(jira_data),
      title: title(jira_data),
      url: url(jira_data),
      type: type(jira_data)
    }
  end

  def key_from_url(nil), do: nil

  def key_from_url(url) do
    url
    |> String.split("/")
    |> List.last()
  end

  defp title(%{"fields" => %{"summary" => title}}), do: title
  defp title(_), do: nil

  defp url(%{"key" => key}), do: "#{Application.fetch_env!(:jira, :host)}/browse/#{key}"
  defp url(_), do: nil

  defp status(%{"fields" => %{"status" => %{"name" => status}}}), do: status
  defp status(_), do: nil

  defp type(%{"fields" => %{"issuetype" => %{"name" => type}}}), do: type
  defp type(_), do: nil
end
