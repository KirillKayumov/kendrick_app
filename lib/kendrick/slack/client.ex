defmodule Kendrick.Slack.Client do
  @users_list_url "https://slack.com/api/users.list"
  @profile_get_url "https://slack.com/api/users.profile.get"

  def users_list(token) do
    response =
      HTTPoison.get!(
        @users_list_url,
        [],
        params: [
          {:token, token}
        ]
      )

    Poison.decode!(response.body)
  end

  def profile_get(token, slack_id) do
    response =
      HTTPoison.get!(
        @profile_get_url,
        [],
        params: [
          {:token, token},
          {:user, slack_id}
        ]
      )

    Poison.decode!(response.body)
  end
end
