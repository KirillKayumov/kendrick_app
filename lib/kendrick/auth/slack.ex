defmodule Kendrick.Auth.Slack do
  alias Kendrick.{
    Repo,
    Slack,
    User,
    Workspace
  }

  def sign_in(conn, credentials) do
    credentials
    |> find_workspace()
    |> find_or_create_user()
    |> do_sign_in(conn)
  end

  def add_to_slack(conn, credentials) do
    credentials
    |> find_workspace()
    |> create_workspace()

    conn
  end

  defp find_workspace(%{other: %{"team_id" => team_id}} = credentials), do: find_workspace(team_id, credentials)
  defp find_workspace(%{other: %{"team" => %{"id" => team_id}}} = credentials), do: find_workspace(team_id, credentials)

  defp find_workspace(team_id, credentials) do
    workspace = Repo.get_by(Workspace, team_id: team_id)

    {credentials, workspace}
  end

  defp create_workspace({_, workspace}) when not is_nil(workspace), do: workspace

  defp create_workspace({credentials, _}) do
    %{
      token: slack_token,
      other: %{
        "team_id" => team_id
      }
    } = credentials

    %Workspace{}
    |> Workspace.changeset(%{
      team_id: team_id,
      slack_token: slack_token,
      slack_users: %{list: slack_users(slack_token)}
    })
    |> Repo.insert!()
  end

  defp slack_users(token) do
    %{"members" => users} = Slack.Client.users_list(token)

    users
    |> Enum.filter(&(!&1["is_bot"]))
    |> Enum.filter(&(&1["id"] != "USLACKBOT"))
  end

  defp find_or_create_user({credentials, workspace}) when is_nil(workspace), do: {credentials, workspace, nil}

  defp find_or_create_user({credentials, workspace}) do
    user =
      case Repo.get_by(User, slack_id: credentials.other["user"]["id"]) do
        nil -> create_user(credentials, workspace)
        user -> user
      end

    {credentials, workspace, user}
  end

  defp create_user(credentials, workspace) do
    %{
      other: %{
        "user" => %{
          "id" => slack_id,
          "name" => name
        }
      }
    } = credentials

    %User{}
    |> User.changeset(%{slack_id: slack_id, name: name})
    |> Ecto.Changeset.put_assoc(:workspace, workspace)
    |> Repo.insert!()
  end

  defp do_sign_in({_, workspace, _}, conn) when is_nil(workspace), do: conn

  defp do_sign_in({_, _, user}, conn) do
    Kendrick.Guardian.Plug.sign_in(conn, user)
  end
end
