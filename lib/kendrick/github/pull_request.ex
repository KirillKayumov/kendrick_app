defmodule Kendrick.Github.PullRequest do
  defstruct [
    :_data,
    :additions,
    :author,
    :closed,
    :color,
    :deletions,
    :merged,
    :open,
    :title
  ]

  def parse(data) do
    %__MODULE__{
      _data: data,
      additions: additions(data),
      author: author(data),
      closed: closed(data),
      color: color(data),
      deletions: deletions(data),
      merged: merged(data),
      open: open(data),
      title: title(data)
    }
  end

  defp additions(%{"additions" => additions}), do: additions
  defp additions(_), do: nil

  defp author(%{"user" => %{"login" => login}}), do: login
  defp author(_), do: nil

  defp closed(%{"state" => "closed"} = data), do: !merged(data)
  defp closed(_), do: false

  defp color(data) do
    cond do
      open(data) -> "#1EC047"
      merged(data) -> "#6f3CC4"
      closed(data) -> "#CD202C"
    end
  end

  defp deletions(%{"deletions" => deletions}), do: deletions
  defp deletions(_), do: nil

  defp merged(%{"merged" => true}), do: true
  defp merged(_), do: false

  defp open(%{"state" => "open"}), do: true
  defp open(_), do: false

  defp title(%{"title" => title}), do: title
  defp title(_), do: nil
end
