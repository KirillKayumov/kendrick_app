defmodule KendrickWeb.HealthCheckController do
  use KendrickWeb, :controller

  def index(conn, _params) do
    send_resp(conn, 200, "")
  end
end
