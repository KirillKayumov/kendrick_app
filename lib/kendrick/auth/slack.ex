defmodule Kendrick.Auth.Slack do
  alias Kendrick.{
    Repo,
    User
  }

  def authenticate(conn, credentials) do
    credentials
    |> find_or_create_user()
    |> sign_in(conn)
  end

  defp find_or_create_user(%{other: %{user_id: slack_id}} = credentials) do
    case Repo.get_by(User, slack_id: slack_id) do
      nil -> create_user(credentials)
      user -> user
    end
  end

  defp create_user(%{other: %{user_id: slack_id}}) do
    %User{}
    |> User.changeset(%{slack_id: slack_id})
    |> Repo.insert!()
  end

  defp sign_in(user, conn) do
    Kendrick.Guardian.Plug.sign_in(conn, user)
  end
end
