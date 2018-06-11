defmodule KendrickWeb.AuthController do
  use KendrickWeb, :controller

  plug(:fetch_session)
  plug(Ueberauth)

  def slack_callback(%{assigns: %{ueberauth_auth: %{credentials: credentials}}} = conn, _params) do
    conn
    |> Kendrick.Auth.Slack.sign_in(credentials)
    |> redirect(to: "/")
  end

  def slack_callback(conn, %{"error" => "access_denied"}) do
    conn
    |> redirect(to: "/")
  end

  def add_to_slack_callback(%{assigns: %{ueberauth_auth: %{credentials: credentials}}} = conn, _params) do
    conn
    |> Kendrick.Auth.Slack.add_to_slack(credentials)
    |> redirect(to: "/")
  end

  def add_to_slack_callback(conn, %{"error" => "access_denied"}) do
    conn
    |> redirect(to: "/")
  end

  def sign_out(conn, _params) do
    conn
    |> Kendrick.Guardian.Plug.sign_out()
    |> redirect(to: "/")
  end
end
