defmodule Kendrick.Jira.Comment do
  def to_map(jira_data) do
    %{
      author: author(jira_data),
      id: id(jira_data),
      text: text(jira_data)
    }
  end

  defp author(%{"author" => %{"displayName" => author}}), do: author
  defp author(_), do: nil

  defp id(%{"id" => id}), do: id
  defp id(_), do: nil

  defp text(%{"body" => text}), do: text
  defp text(_), do: nil
end
