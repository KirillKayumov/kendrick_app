defmodule KendrickWeb.UserController do
  use KendrickWeb, :controller

  plug(Guardian.Plug.EnsureAuthenticated)

  def index(conn, _params) do
    conn
    |> Plug.Conn.assign(:users, Kendrick.Users.for_workspace(current_workspace(conn)))
    |> render("index.html")
  end

  def add_to_app(conn, %{"slack_id" => slack_id}) do
    Kendrick.Users.AddToApp.call(slack_id, current_workspace(conn))

    conn
    |> redirect(to: Routes.user_path(conn, :index))
  end
end
