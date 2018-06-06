defmodule KendrickWeb.SlackUserController do
  use KendrickWeb, :controller

  def index(conn, _params) do
    %{current_workspace: current_workspace} = conn.assigns

    conn
    |> assign(:slack_users, current_workspace.slack_users["list"])
    |> render("index.html")
  end

  def refresh(conn, _params) do
    conn
    |> assign(:current_workspace, refresh_slack_users(conn))
    |> redirect(to: slack_user_path(conn, :index))
  end

  defp refresh_slack_users(conn) do
    %{current_workspace: current_workspace, current_user: current_user} = conn.assigns

    Kendrick.Workspaces.refresh_slack_users(current_workspace, current_user)
  end
end
