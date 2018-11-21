defmodule Kendrick.Jira.API do
  use HTTPoison.Base

  defp config(key) do
    Application.get_env(:kendrick, __MODULE__)[key]
  end

  defp host do
    config(:host)
  end

  defp username do
    config(:username)
  end

  defp password do
    config(:password)
  end

  ### HTTPoison.Base callbacks
  def process_url(url) do
    host() <> url
  end

  def process_response_body(body) do
    body
    |> decode_body()
  end

  def process_request_headers(headers) do
    [{"authorization", authorization_header()} | headers]
  end

  defp decode_body(""), do: ""
  defp decode_body(body), do: body |> Poison.decode!()

  ### Internal Helpers
  def authorization_header do
    credentials = encoded_credentials(username(), password())
    "Basic #{credentials}"
  end

  defp encoded_credentials(user, pass) do
    "#{user}:#{pass}"
    |> Base.encode64()
  end

  def ticket_details(key) do
    get!("/rest/api/2/issue/#{key}").body
  end

  def search(query) do
    body = query |> Poison.encode!()
    post!("/rest/api/2/search", body, [{"Content-type", "application/json"}])
  end
end
