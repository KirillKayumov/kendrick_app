defmodule KendrickWeb.AuthController do
  use KendrickWeb, :controller

  plug(Ueberauth)

  def callback(conn, _params) do
    conn
    |> redirect(to: "/")
  end
end
