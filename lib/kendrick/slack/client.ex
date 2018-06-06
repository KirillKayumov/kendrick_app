defmodule Kendrick.Slack.Client do
  @users_list_url "https://slack.com/api/users.list"

  def users_list(token) do
    response = HTTPoison.get!(
      @users_list_url,
      [],
      params: [
        {:token, token}
      ]
    )

    Poison.decode!(response.body)
  end
end
