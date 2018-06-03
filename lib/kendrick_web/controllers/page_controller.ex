defmodule KendrickWeb.PageController do
  use KendrickWeb, :controller

  plug(KendrickWeb.Plugs.HomePagePipeline)

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
