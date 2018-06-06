defmodule KendrickWeb.SlackUserController do
  use KendrickWeb, :controller

  def index(conn, _params) do
    conn
    |> assign(:slack_users, Kendrick.Users.workspace_members(current_workspace(conn)))
    |> render("index.html")
  end

  def refresh(conn, _params) do
    conn
    |> assign(:current_workspace, refresh_slack_users(conn))
    |> redirect(to: slack_user_path(conn, :index))
  end

  defp refresh_slack_users(conn) do
    Kendrick.Workspaces.refresh_slack_users(current_workspace(conn), current_user(conn))
  end
end
