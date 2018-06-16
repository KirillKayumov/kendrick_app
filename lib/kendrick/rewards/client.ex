defmodule Kendrick.Rewards.Client do
  @rewards_url System.get_env("REWARDS_URL")
  @bonus_possibilities_url "#{@rewards_url}/api/v1/user/bonus_possibilities"

  @default_options [timeout: 30000, recv_timeout: 30000]

  def bonus_possibilities(token) do
    response =
      HTTPoison.get!(
        @bonus_possibilities_url,
        [
          {"Content-Type", "application/vnd.api+json"},
          {"Accept", "application/vnd.api+json"},
          {"Authorization", "Bearer #{token}"}
        ],
        @default_options
      )

    Poison.decode!(response.body)
  end
end
