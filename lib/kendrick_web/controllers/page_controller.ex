defmodule KendrickWeb.PageController do
  use KendrickWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
