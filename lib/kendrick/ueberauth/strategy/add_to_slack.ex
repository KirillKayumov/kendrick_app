defmodule Kendrick.Ueberauth.Strategy.AddToSlack do
  use Ueberauth.Strategy,
    default_scope: "bot,chat:write:bot,commands",
    oauth2_module: Kendrick.Ueberauth.Strategy.Slack.OAuth

  alias Ueberauth.Auth.Info
  alias Ueberauth.Auth.Credentials
  alias Ueberauth.Auth.Extra

  def handle_request!(conn) do
    scopes = conn.params["scope"] || option(conn, :default_scope)
    opts = [scope: scopes]
    opts = if conn.params["state"], do: Keyword.put(opts, :state, conn.params["state"]), else: opts

    team = option(conn, :team)
    opts = if team, do: Keyword.put(opts, :team, team), else: opts

    callback_url = callback_url(conn)

    callback_url = if String.ends_with?(callback_url, "?"), do: String.slice(callback_url, 0..-2), else: callback_url

    opts = Keyword.put(opts, :redirect_uri, callback_url)
    module = option(conn, :oauth2_module)

    redirect!(conn, apply(module, :authorize_url!, [opts, client_credentials()]))
  end

  def handle_callback!(%Plug.Conn{params: %{"code" => code}} = conn) do
    module = option(conn, :oauth2_module)
    params = [code: code]
    redirect_uri = get_redirect_uri(conn)

    options = [
      options: [
        client_options: Keyword.merge([redirect_uri: redirect_uri], client_credentials())
      ]
    ]

    token = apply(module, :get_token!, [params, options])

    if token.access_token == nil do
      set_errors!(conn, [error(token.other_params["error"], token.other_params["error_description"])])
    else
      conn
      |> store_token(token)
    end
  end

  def handle_callback!(conn) do
    set_errors!(conn, [error("missing_code", "No code received")])
  end

  defp store_token(conn, token) do
    put_private(conn, :slack_token, token)
  end

  def handle_cleanup!(conn) do
    conn
    |> put_private(:slack_token, nil)
  end

  def uid(_conn), do: nil

  def credentials(conn) do
    token = conn.private.slack_token

    %Credentials{
      token: token.access_token,
      other: token.other_params
    }
  end

  def info(_conn), do: %Info{}

  def extra(_conn), do: %Extra{}

  defp option(conn, key) do
    Keyword.get(options(conn), key, Keyword.get(default_options(), key))
  end

  defp get_redirect_uri(%Plug.Conn{} = conn) do
    config = Application.get_env(:ueberauth, Ueberauth)
    redirect_uri = Keyword.get(config, :redirect_uri)

    if is_nil(redirect_uri) do
      callback_url(conn)
    else
      redirect_uri
    end
  end

  defp client_credentials do
    [
      client_id: System.get_env("ADD_TO_SLACK_CLIENT_ID"),
      client_secret: System.get_env("ADD_TO_SLACK_CLIENT_SECRET")
    ]
  end
end
