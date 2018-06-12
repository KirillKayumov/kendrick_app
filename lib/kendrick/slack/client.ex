defmodule Kendrick.Slack.Client do
  @post_message_url "https://slack.com/api/chat.postMessage"
  @profile_get_url "https://slack.com/api/users.profile.get"
  @users_list_url "https://slack.com/api/users.list"

  def post_message(text, channel, token) when is_binary(text) do
    post_message(text, "", channel, token)
  end

  def post_message(attachments, channel, token) when is_map(attachments) do
    post_message("", attachments, channel, token)
  end

  def post_message(message, attachments, channel, token) do
    response =
      HTTPoison.post!(
        @post_message_url,
        {
          :form,
          [
            {"attachments", Poison.encode!(attachments)},
            {"channel", channel},
            {"text", message},
            {"token", token}
          ]
        },
        [
          {"Content-Type", "multipart/form-data"}
        ]
      )

    Poison.decode!(response.body)
  end

  def profile_get(slack_id, token) do
    response =
      HTTPoison.get!(
        @profile_get_url,
        [],
        params: [
          {:user, slack_id},
          {:token, token}
        ]
      )

    Poison.decode!(response.body)
  end

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
end
