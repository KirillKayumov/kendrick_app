defmodule Kendrick.Rewards do
  @rewards_url System.get_env("REWARDS_URL")
  @user_token_url "#{@rewards_url}/api/v1/user/tokens"

  def connect(params, user) do
    response =
      HTTPoison.post!(
        @user_token_url,
        Poison.encode!(%{
          data: %{
            type: "user-token-requests",
            attributes: %{
              email: params["email"],
              password: params["password"]
            }
          }
        }),
        [
          {"Content-Type", "application/vnd.api+json"},
          {"Accept", "application/vnd.api+json"}
        ]
      )

    response = Poison.decode!(response.body)

    user
    |> Kendrick.User.changeset(%{rewards_token: response["data"]["attributes"]["token"]})
    |> Kendrick.Repo.update!()
  end

  def disconnect(user) do
    user
    |> Kendrick.User.changeset(%{rewards_token: nil})
    |> Kendrick.Repo.update!()
  end
end
