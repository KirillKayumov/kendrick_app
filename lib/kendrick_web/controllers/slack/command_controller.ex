defmodule KendrickWeb.Slack.CommandController do
  use KendrickWeb, :controller

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

  def index(conn, %{"command" => "/add_task"} = params) do
    Kendrick.Slack.Commands.AddTask.call(params)

    conn
    |> send_resp(200, "")
  end
end
