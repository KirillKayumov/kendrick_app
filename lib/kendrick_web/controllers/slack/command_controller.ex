defmodule KendrickWeb.Slack.CommandController do
  use KendrickWeb, :controller

  def index(conn, %{"command" => "/start"} = params) do
    Kendrick.Slack.Commands.Start.call(params)

    conn
    |> send_resp(200, "")
  end

  def index(conn, _params) do
    conn
    |> send_resp(200, "")
  end
end
