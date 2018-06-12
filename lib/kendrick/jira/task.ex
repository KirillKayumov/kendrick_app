defmodule Kendrick.Jira.Task do
  # alias Kendrick.Jira.Task

  defstruct [
    # :key,
    :status,
    :title,
    :url
    # :type,
  ]

  def to_map(jira_data) do
    %{
      # key: jira_data["key"],
      status: status(jira_data),
      title: title(jira_data),
      url: url(jira_data)
      # type: type(jira_data),
    }
  end

  # def to_ticket(jira_ticket) do
  #   %Ticket{
  #     title: jira_ticket.title,
  #     url: jira_ticket.url,
  #     status: jira_ticket.status,
  #     type: jira_ticket.type,
  #   }
  # end

  defp title(%{"fields" => %{"summary" => title}}), do: title

  defp url(%{"key" => key}), do: "#{Application.fetch_env!(:jira, :host)}/browse/#{key}"

  defp status(%{"fields" => %{"status" => %{"name" => status}}}), do: status

  # defp type(%{ "fields" => %{ "issuetype" => %{ "name" => type } } }), do: type
end
