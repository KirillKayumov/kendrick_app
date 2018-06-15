defmodule KendrickWeb.RewardsController do
  use KendrickWeb, :controller

  def show(conn, params) do
    conn
    |> assign(:current_user, current_user(conn))
    |> render("show.html")
  end

  def create(conn, params) do
    Kendrick.Rewards.connect(params, current_user(conn))

    conn
    |> redirect(to: rewards_path(conn, :show))
  end

  def delete(conn, _params) do
    Kendrick.Rewards.disconnect(current_user(conn))

    conn
    |> redirect(to: rewards_path(conn, :show))
  end
end
