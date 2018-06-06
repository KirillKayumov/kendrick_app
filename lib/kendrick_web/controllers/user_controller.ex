defmodule KendrickWeb.UserController do
  use KendrickWeb, :controller

  plug(Guardian.Plug.EnsureAuthenticated)

  def index(conn, _params) do
    conn
    |> Plug.Conn.assign(:slack_users, [])
    |> Plug.Conn.assign(:users, [])
    |> render("index.html")
  end

  def add_to_app(conn, %{"slack_id" => slack_id}) do
    %{current_workspace: current_workspace} = conn.assigns

    Kendrick.Users.AddToApp.call(slack_id, current_workspace)

    conn
    |> redirect(to: user_path(conn, :index))
  end
end
