defmodule Kendrick.Workspaces do
  alias Kendrick.{
    Repo,
    User,
    Workspace
  }

  def for_user(nil), do: nil
  def for_user(%User{workspace_id: workspace_id}) do
    Repo.get(Workspace, workspace_id)
  end
end
