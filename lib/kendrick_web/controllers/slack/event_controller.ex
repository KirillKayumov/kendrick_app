defmodule KendrickWeb.Slack.EventController do
  use KendrickWeb, :controller

  def index(conn, %{"event" => %{"type" => "team_join", "user" => user}}) do
    Kendrick.Slack.Events.Users.TeamJoin.call(user)

    conn
    |> send_resp(200, "")
  end
end
