defmodule Kendrick.Auth.ErrorHandler do
  def auth_error(conn, {type, _reason}, _opts) do
    case type do
      :unauthenticated -> redirect_to_home(conn)
      :invalid_token -> redirect_to_home(conn)
    end
  end

  defp redirect_to_home(conn) do
    Phoenix.Controller.redirect(conn, to: "/")
  end
end
