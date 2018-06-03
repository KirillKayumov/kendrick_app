defmodule KendrickWeb.Plugs.SetCurrentUser do
  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    assign(conn, :current_user, conn.private[:guardian_default_resource])
  end
end
