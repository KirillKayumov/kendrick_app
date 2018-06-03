defmodule KendrickWeb.AuthController do
  use KendrickWeb, :controller

  plug(:fetch_session)
  plug(Ueberauth)

  def callback(%{assigns: %{ueberauth_auth: %{credentials: credentials}}} = conn, _params) do
    conn
    |> Kendrick.Auth.Slack.authenticate(credentials)
    |> redirect(to: "/")
  end
end
