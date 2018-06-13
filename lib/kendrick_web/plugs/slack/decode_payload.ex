defmodule KendrickWeb.Plugs.Slack.DecodePayload do
  def init(opts) do
    opts
  end

  def call(%{params: %{"payload" => payload}} = conn, _opts) do
    params = Poison.decode!(payload)

    Map.put(conn, :params, params)
  end

  def call(conn, _opts), do: conn
end
