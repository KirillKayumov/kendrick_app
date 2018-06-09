defmodule KendrickWeb.Plugs.VerifySlackVerificationToken do
  import Plug.Conn

  @token System.get_env("SLACK_VERIFICATION_TOKEN")

  def init(opts) do
    opts
  end

  def call(%{params: %{"token" => token}} = conn, _opts) when token == @token, do: conn

  def call(conn, _opts) do
    conn
    |> send_resp(401, "")
    |> halt()
  end
end
