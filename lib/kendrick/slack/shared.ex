defmodule Kendrick.Slack.Shared do
  alias Kendrick.{
    Repo,
    Workspace
  }

  def find_workspace(%{params: %{"team_id" => team_id}} = data), do: do_find_workspace(team_id, data)
  def find_workspace(%{params: %{"team" => %{"id" => team_id}}} = data), do: do_find_workspace(team_id, data)

  defp do_find_workspace(team_id, data) do
    workspace = Repo.get_by(Workspace, team_id: team_id)

    {:ok, Map.put(data, :workspace, workspace)}
  end
end
