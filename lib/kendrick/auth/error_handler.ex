defmodule Kendrick.Auth.ErrorHandler do
  import Plug.Conn

  def auth_error(_conn, {type, reason}, _opts) do
  end
end
