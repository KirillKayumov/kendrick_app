defmodule KendrickWeb.Slack.EventController do
  use KendrickWeb, :controller

  def index(conn, %{"event" => %{"type" => "reaction_added", "item" => %{"type" => "message"}}} = params) do
    Kendrick.Slack.Events.ReactionAdded.call(params)

    send_resp(conn, 200, "")
  end

  def index(conn, %{"event" => %{"type" => "link_shared"}} = params) do
    Kendrick.Slack.Events.LinkShared.call(params)

    send_resp(conn, 200, "")
  end

  def index(conn, params) do
    send_resp(conn, 200, "")
  end
end
