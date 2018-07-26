defmodule KendrickWeb.Slack.ActionController do
  use KendrickWeb, :controller

  alias Kendrick.Slack.Actions.{
    Tasks,
    ProjectReport,
    Todos
  }

  plug(KendrickWeb.Plugs.Slack.EnsureUserExists)

  def index(conn, %{"ssl_check" => _ssl_check}) do
    send_resp(conn, 200, "")
  end

  def index(conn, %{"actions" => [%{"name" => "task_add"}]} = params) do
    Tasks.ShowNewForm.call(params)

    send_resp(conn, 200, "")
  end

  def index(conn, %{"actions" => [%{"name" => "task_status"}]} = params) do
    Tasks.UpdateStatus.call(params)

    send_resp(conn, 200, "")
  end

  def index(conn, %{"actions" => [%{"name" => "task_more"}]} = params) do
    Tasks.More.call(params)

    send_resp(conn, 200, "")
  end

  def index(conn, %{"actions" => [%{"name" => "task_edit"}]} = params) do
    Tasks.ShowEditForm.call(params)

    send_resp(conn, 200, "")
  end

  def index(conn, %{"actions" => [%{"name" => "task_delete"}]} = params) do
    Tasks.Delete.call(params)

    send_resp(conn, 200, "")
  end

  def index(conn, %{"actions" => [%{"name" => "todo_done"}]} = params) do
    Todos.Done.call(params)

    send_resp(conn, 200, "")
  end

  def index(conn, %{"actions" => [%{"name" => "todo_delete"}]} = params) do
    Todos.Delete.call(params)

    send_resp(conn, 200, "")
  end

  def index(conn, %{"actions" => [%{"name" => "project_report"}]} = params) do
    ProjectReport.Show.call(params)

    send_resp(conn, 200, "")
  end

  def index(conn, %{"actions" => [%{"name" => "project_report_post"}]} = params) do
    ProjectReport.Post.call(params)

    send_resp(conn, 200, "")
  end

  def index(conn, params) do
    action = Poison.decode!(params["callback_id"])["action"]

    case action do
      "task_add" -> task_add(conn, params)
      "task_edit" -> task_edit(conn, params)
    end
  end

  defp task_add(conn, params) do
    body =
      case Tasks.Create.call(params) do
        {:ok, _} -> ""
        {:error, errors} -> errors
      end

    send_resp(conn, 200, body)
  end

  defp task_edit(conn, params) do
    body =
      case Tasks.Update.call(params) do
        {:ok, _} -> ""
        {:error, errors} -> errors
      end

    send_resp(conn, 200, body)
  end
end
