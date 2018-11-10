defmodule KendrickWeb.SlackUserController do
  use KendrickWeb, :controller

  plug(Guardian.Plug.EnsureAuthenticated)

  def index(conn, _params) do
    conn
    |> assign(:slack_users, Kendrick.Users.workspace_members(current_workspace(conn)))
    |> render("index.html")
  end

  def add_to_app(conn, %{"slack_id" => slack_id}) do
    Kendrick.Users.AddToApp.call(slack_id, current_workspace(conn))

    conn
    |> redirect(to: Routes.slack_user_path(conn, :index))
  end
end
