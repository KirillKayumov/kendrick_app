defmodule KendrickWeb.AuthController do
  use KendrickWeb, :controller

  plug(:fetch_session)
  plug(Ueberauth)

  def callback(%{assigns: %{ueberauth_auth: %{credentials: credentials}}} = conn, _params) do
    conn
    |> Kendrick.Auth.Slack.authenticate(credentials)
    |> redirect(to: "/")
  end

  def callback(conn, %{"error" => "access_denied"}) do
    conn
    |> redirect(to: "/")
  end

  def sign_out(conn, _params) do
    conn
    |> Kendrick.Guardian.Plug.sign_out()
    |> redirect(to: "/")
  end
end
