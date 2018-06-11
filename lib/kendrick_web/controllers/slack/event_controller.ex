defmodule KendrickWeb.Slack.EventController do
  use KendrickWeb, :controller

  def index(conn, %{"challenge" => challenge}) do
    conn
    |> send_resp(200, challenge)
  end

  def index(conn, %{"event" => %{"type" => "team_join", "user" => user}}) do
    Kendrick.Slack.Events.Users.TeamJoin.call(user)

    conn
    |> send_resp(200, "")
  end

  def index(conn, params) do
    IO.inspect(params)

    conn
    |> send_resp(200, "")
  end
end
