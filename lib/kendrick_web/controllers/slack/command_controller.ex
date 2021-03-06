defmodule KendrickWeb.Slack.CommandController do
  use KendrickWeb, :controller

  plug(KendrickWeb.Plugs.Slack.EnsureUserExists)

  def index(conn, %{"command" => "/start"} = params) do
    Kendrick.Slack.Commands.Start.call(params)

    conn
    |> send_resp(200, "")
  end

  def index(conn, %{"command" => "/report"} = params) do
    Kendrick.Slack.Commands.Report.call(params)

    conn
    |> send_resp(200, "")
  end

  def index(conn, %{"command" => "/todo"} = params) do
    Kendrick.Slack.Commands.Todo.create(params)

    send_resp(conn, 200, "")
  end
end
