defmodule Kendrick.Auth.Slack do
  import OK, only: [~>>: 2]

  alias Kendrick.{
    Repo,
    User,
    Workspace
  }

  def sign_in(conn, %{other: %{"user" => _user}} = credentials) do
    %{conn: conn, credentials: credentials}
    |> find_workspace()
    ~>> find_user()
    ~>> update_user_token()
    ~>> do_sign_in()
    |> get_conn()
  end

  def sign_in(conn, credentials) do
    %{conn: conn, credentials: credentials}
    |> find_workspace()
    ~>> update_bot_token()
    |> create_workspace()
    |> get_conn()
  end

  defp find_workspace(%{credentials: %{other: %{"team_id" => team_id}}} = data),
    do: find_workspace(team_id, data)

  defp find_workspace(%{credentials: %{other: %{"team" => %{"id" => team_id}}}} = data),
    do: find_workspace(team_id, data)

  defp find_workspace(team_id, data) do
    workspace = Repo.get_by(Workspace, team_id: team_id)

    case workspace do
      nil -> {:error, data}
      _ -> {:ok, Map.put(data, :workspace, workspace)}
    end
  end

  defp find_user(%{credentials: %{other: %{"user" => %{"id" => user_id}}}} = data) do
    user = Repo.get_by(User, slack_id: user_id)

    case user do
      nil -> {:error, data}
      _ -> {:ok, Map.put(data, :user, user)}
    end
  end

  defp update_user_token(%{credentials: %{token: slack_token}, user: user} = data) do
    user =
      user
      |> User.changeset(%{slack_token: slack_token})
      |> Repo.update!()

    {:ok, Map.put(data, :user, user)}
  end

  defp do_sign_in(%{conn: conn, user: user} = data) do
    conn = Kendrick.Guardian.Plug.sign_in(conn, user)

    {:ok, Map.put(data, :conn, conn)}
  end

  defp get_conn({:ok, %{conn: conn}}), do: conn
  defp get_conn({:error, %{conn: conn}}), do: conn

  defp create_workspace({:ok, data}), do: {:ok, data}

  defp create_workspace({:error, %{credentials: credentials} = data}) do
    %{
      other: %{
        "bot" => %{
          "bot_access_token" => slack_token
        },
        "team_id" => team_id
      }
    } = credentials

    workspace =
      %Workspace{}
      |> Workspace.changeset(%{team_id: team_id, slack_token: slack_token})
      |> Repo.insert!()

    {:ok, Map.put(data, :workspace, workspace)}
  end

  defp update_bot_token(%{credentials: credentials, workspace: workspace} = data) do
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

    {:ok, Map.put(data, :workspace, workspace)}
  end
end
