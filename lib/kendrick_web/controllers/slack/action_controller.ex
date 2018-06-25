defmodule KendrickWeb.Slack.ActionController do
  use KendrickWeb, :controller

  alias Kendrick.Slack.Actions.{
    Tasks,
    Todos
  }

  plug(KendrickWeb.Plugs.Slack.EnsureUserExists)

  def index(conn, %{"ssl_check" => _ssl_check}) do
    send_resp(conn, 200, "")
  end

  def index(conn, %{"actions" => [%{"value" => "add_task"}]} = params) do
    Tasks.ShowNewForm.call(params)

    send_resp(conn, 200, "")
  end

  def index(conn, %{"callback_id" => "add_task"} = params) do
    body =
      case Tasks.Create.call(params) do
        {:ok, _} -> ""
        {:error, errors} -> errors
      end

    send_resp(conn, 200, body)
  end

  def index(conn, %{"actions" => [%{"name" => "task_status"}]} = params) do
    Tasks.UpdateStatus.call(params)

    send_resp(conn, 200, "")
  end

  def index(conn, %{"actions" => [%{"name" => "todo_done"}]} = params) do
    Todos.Done.call(params)

    send_resp(conn, 200, "")
  end
end
