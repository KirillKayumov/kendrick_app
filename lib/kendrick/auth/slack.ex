defmodule Kendrick.Auth.Slack do
  alias Kendrick.{
    Repo,
    User,
    Workspace
  }

  def authenticate(conn, credentials) do
    credentials
    |> find_or_create_workspace()
    |> find_or_create_user()
    |> sign_in(conn)
  end

  defp find_or_create_workspace(%{other: %{team_id: team_id}} = credentials) do
    workspace = case Repo.get_by(Workspace, team_id: team_id) do
      nil -> create_workspace(credentials)
      workspace -> workspace
    end

    Map.put(credentials, :workspace, workspace)
  end

  defp create_workspace(%{other: %{team_id: team_id}}) do
    %Workspace{}
    |> Workspace.changeset(%{team_id: team_id})
    |> Repo.insert!()
  end

  defp find_or_create_user(%{other: %{user_id: slack_id}} = credentials) do
    user = case Repo.get_by(User, slack_id: slack_id) do
      nil -> create_user(credentials)
      user -> user
    end

    Map.put(credentials, :user, user)
  end

  defp create_user(%{other: %{user_id: slack_id}, workspace: workspace}) do
    %User{}
    |> User.changeset(%{slack_id: slack_id})
    |> Ecto.Changeset.put_assoc(:workspace, workspace)
    |> Repo.insert!()
  end

  defp sign_in(%{user: user}, conn) do
    Kendrick.Guardian.Plug.sign_in(conn, user)
  end
end
