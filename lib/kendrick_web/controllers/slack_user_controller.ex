defmodule KendrickWeb.SlackUserController do
  use KendrickWeb, :controller

  def index(conn, _params) do
    conn
    |> assign(:slack_users, Kendrick.Users.workspace_members(current_workspace(conn)))
    |> render("index.html")
  end
end
