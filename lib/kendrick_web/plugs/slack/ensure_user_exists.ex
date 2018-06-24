defmodule KendrickWeb.Plugs.Slack.EnsureUserExists do
  import Plug.Conn

  alias Kendrick.{
    Slack,
    Users
  }

  def init(opts) do
    opts
  end

  def call(%{params: %{"ssl_check" => _ssl_check}} = conn, _opts), do: conn
  def call(%{params: %{"command" => "/start"}} = conn, _opts), do: conn

  def call(%{params: %{"user_id" => slack_id}} = conn, _opts), do: ensure_user_exists(conn, slack_id)
  def call(%{params: %{"user" => %{"id" => slack_id}}} = conn, _opts), do: ensure_user_exists(conn, slack_id)

  defp ensure_user_exists(conn, slack_id) do
    case Users.get_by(slack_id: slack_id) do
      nil ->
        Slack.NoUserNotifier.call(conn.params)

        conn
        |> send_resp(200, "")
        |> halt()

      _ ->
        conn
    end
  end
end
