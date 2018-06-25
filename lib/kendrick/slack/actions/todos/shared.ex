defmodule Kendrick.Slack.Actions.Todos.Shared do
  alias Kendrick.{
    Slack,
    Todos
  }

  def find_todo(%{params: params} = data) do
    todo = Todos.get(params["callback_id"])

    {:ok, Map.put(data, :todo, todo)}
  end

  def update_report(%{params: params, user: user, workspace: workspace}) do
    Slack.Client.respond(%{
      attachments: Slack.Report.build(user),
      token: workspace.slack_token,
      url: params["response_url"]
    })
  end
end
