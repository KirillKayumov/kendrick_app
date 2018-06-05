defmodule KendrickWeb.UserController do
  use KendrickWeb, :controller

  plug(Guardian.Plug.EnsureAuthenticated)

  def index(conn, _params) do
    %{
      current_user: current_user,
      current_workspace: current_workspace
    } = conn.assigns

    response =
      HTTPoison.get!(
        "https://slack.com/api/users.list",
        [],
        params: [{:token, current_user.slack_token}]
      )

    %{"members" => slack_users} = Poison.decode!(response.body)
    users = Kendrick.Users.for_workspace(current_workspace)

    conn
    |> Plug.Conn.assign(:slack_users, slack_users)
    |> Plug.Conn.assign(:users, users)
    |> render("index.html")
  end

  def add_to_app(conn, %{"slack_id" => slack_id}) do
    %{current_workspace: current_workspace} = conn.assigns

    Kendrick.Users.AddToApp.call(slack_id, current_workspace)

    conn
    |> redirect(to: user_path(conn, :index))
  end
end
