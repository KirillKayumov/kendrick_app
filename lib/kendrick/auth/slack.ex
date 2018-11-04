defmodule Kendrick.Auth.Slack do
  alias Kendrick.{
    Repo,
    User,
    Workspace
  }

  def sign_in(conn, credentials) do
    credentials
    |> find_workspace()
    |> find_user()
    |> do_sign_in(conn)
  end

  def add_to_slack(credentials) do
    credentials
    |> find_workspace()
    |> update_token()
    |> create_workspace()
  end

  defp find_workspace(%{other: %{"team_id" => team_id}} = credentials),
    do: find_workspace(team_id, credentials)

  defp find_workspace(%{other: %{"team" => %{"id" => team_id}}} = credentials),
    do: find_workspace(team_id, credentials)

  defp find_workspace(team_id, credentials) do
    workspace = Repo.get_by(Workspace, team_id: team_id)

    {credentials, workspace}
  end

  defp update_token({_, workspace} = attrs) when is_nil(workspace), do: attrs

  defp update_token({credentials, workspace}) do
    %{
      other: %{
        "bot" => %{
          "bot_access_token" => slack_token
        }
      }
    } = credentials

    workspace =
      workspace
      |> Workspace.changeset(%{slack_token: slack_token})
      |> Repo.update!()

    {credentials, workspace}
  end

  defp create_workspace({_, workspace}) when not is_nil(workspace), do: workspace

  defp create_workspace({credentials, _}) do
    %{
      other: %{
        "bot" => %{
          "bot_access_token" => slack_token
        },
        "team_id" => team_id
      }
    } = credentials

    %Workspace{}
    |> Workspace.changeset(%{team_id: team_id, slack_token: slack_token})
    |> Repo.insert!()
  end

  defp find_user({credentials, workspace}) when is_nil(workspace), do: {credentials, workspace, nil}

  defp find_user({credentials, workspace}) do
    user = Repo.get_by(User, slack_id: credentials.other["user"]["id"])

    {credentials, workspace, user}
  end

  defp do_sign_in({_, workspace, _}, conn) when is_nil(workspace), do: conn
  defp do_sign_in({_, _, user}, conn) when is_nil(user), do: conn

  defp do_sign_in({_, _, user}, conn) do
    Kendrick.Guardian.Plug.sign_in(conn, user)
  end
end
