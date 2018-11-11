defmodule KendrickWeb.Plugs.Slack.Challenge do
  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(%{params: %{"challenge" => challenge}} = conn, _opts) do
    conn
    |> send_resp(200, challenge)
    |> halt()
  end

  def call(conn, _opts), do: conn
end
