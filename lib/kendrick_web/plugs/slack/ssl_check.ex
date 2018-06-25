defmodule KendrickWeb.Plugs.Slack.SslCheck do
  import Plug.Conn

  alias Kendrick.{
    Slack,
    Users
  }

  def init(opts) do
    opts
  end

  def call(%{params: %{"ssl_check" => _ssl_check}} = conn, _opts) do
    conn
    |> send_resp(200, "")
    |> halt()
  end

  def call(conn, _opts), do: conn
end
