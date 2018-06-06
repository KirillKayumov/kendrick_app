defmodule Kendrick.Auth.Slack do
  alias Kendrick.{
    Repo,
    Slack,
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
    workspace =
      case Repo.get_by(Workspace, team_id: team_id) do
        nil -> create_workspace(credentials)
        workspace -> workspace
      end

    Map.put(credentials, :workspace, workspace)
  end

  defp create_workspace(credentials) do
    credentials
    |> save_workspace()
    |> save_slack_users(credentials)
  end

  defp save_workspace(%{other: %{team_id: team_id}}) do
    %Workspace{}
    |> Workspace.changeset(%{team_id: team_id})
    |> Repo.insert!()
  end

  defp save_slack_users(workspace, %{token: slack_token}) do
    %{"members" => users} = Slack.Client.users_list(slack_token)
    users = Enum.filter(users, &(&1["id"] != "USLACKBOT"))

    workspace
    |> Workspace.changeset(%{slack_users: %{list: users}})
    |> Repo.update!()
  end

  defp find_or_create_user(%{other: %{user_id: slack_id}} = credentials) do
    user =
      case Repo.get_by(User, slack_id: slack_id) do
        nil -> create_user(credentials)
        user -> set_token(user, credentials)
      end

    Map.put(credentials, :user, user)
  end

  defp create_user(credentials) do
    credentials
    |> save_user()
    |> save_profile_info()
  end

  defp save_user(%{other: %{user_id: slack_id}, token: slack_token, workspace: workspace}) do
    %User{}
    |> User.changeset(%{slack_id: slack_id, slack_token: slack_token})
    |> Ecto.Changeset.put_assoc(:workspace, workspace)
    |> Repo.insert!()
  end

  defp save_profile_info(user) do
    %{"profile" => %{"real_name" => name}} = Kendrick.Slack.Client.profile_get(user.slack_token, user.slack_id)

    user
    |> User.changeset(%{name: name})
    |> Repo.update!()
  end

  defp set_token(user, %{token: slack_token}) do
    user
    |> User.changeset(%{slack_token: slack_token})
    |> Repo.update!()
  end

  defp sign_in(%{user: user}, conn) do
    Kendrick.Guardian.Plug.sign_in(conn, user)
  end
end
