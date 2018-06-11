defmodule KendrickWeb.Slack.CommandController do
  use KendrickWeb, :controller

  def index(conn, _params) do
    conn
    |> send_resp(200, "")
  end
end
