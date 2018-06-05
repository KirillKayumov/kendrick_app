defmodule Kendrick.Auth.ErrorHandler do
  def auth_error(conn, {type, _reason}, _opts) do
    case type do
      :unauthenticated -> Phoenix.Controller.redirect(conn, to: "/")
    end
  end
end
