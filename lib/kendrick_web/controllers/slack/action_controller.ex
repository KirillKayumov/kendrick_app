defmodule KendrickWeb.Slack.ActionController do
  use KendrickWeb, :controller

  def index(conn, %{"ssl_check" => _ssl_check}) do
    send_resp(conn, 200, "")
  end

  def index(conn, %{"actions" => [%{"value" => "add_task"}]} = params) do
    Kendrick.Slack.Commands.AddTask.open_form(params)

    conn
    |> send_resp(200, "")
  end

  def index(conn, %{"callback_id" => "add_task"} = params) do
    body =
      case Kendrick.Slack.Commands.AddTask.save_task(params) do
        :ok -> ""
        {:error, errors} -> errors
      end

    send_resp(conn, 200, body)
  end
end
