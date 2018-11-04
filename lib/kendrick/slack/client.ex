defmodule Kendrick.Slack.Client do
  @chat_post_ephemeral_url "https://slack.com/api/chat.postEphemeral"
  @chat_update_url "https://slack.com/api/chat.update"
  @dialog_open_url "https://slack.com/api/dialog.open"
  @files_upload_url "https://slack.com/api/files.upload"
  @post_message_url "https://slack.com/api/chat.postMessage"
  @profile_get_url "https://slack.com/api/users.profile.get"
  @users_info_url "https://slack.com/api/users.info"
  @users_list_url "https://slack.com/api/users.list"

  def respond(%{url: url, token: token} = data) do
    response =
      HTTPoison.post!(
        url,
        Poison.encode!(%{
          attachments: data[:attachments] || [],
          text: data[:text] || ""
        }),
        headers(token)
      )

    Poison.decode!(response.body)
  end

  def chat_post_ephemeral(text, channel, user, token) do
    response =
      HTTPoison.post!(
        @chat_post_ephemeral_url,
        {
          :form,
          [
            {"text", text},
            {"channel", channel},
            {"user", user},
            {"token", token}
          ]
        },
        [
          {"Content-Type", "multipart/form-data"}
        ]
      )

    Poison.decode!(response.body)
  end

  def chat_update(%{token: token, channel: channel, ts: ts} = data) do
    response =
      HTTPoison.post!(
        @chat_update_url,
        Poison.encode!(%{
          attachments: data[:attachments] || [],
          channel: channel,
          text: data[:text] || "",
          ts: ts
        }),
        headers(token)
      )

    Poison.decode!(response.body)
  end

  def dialog_open(dialog, trigger_id, token) do
    response =
      HTTPoison.post!(
        @dialog_open_url,
        {
          :form,
          [
            {"dialog", Poison.encode!(dialog)},
            {"trigger_id", trigger_id},
            {"token", token}
          ]
        },
        [
          {"Content-Type", "multipart/form-data"}
        ]
      )

    Poison.decode!(response.body)
  end

  def files_upload(%{token: token, channel: channel, text: text, title: title} = data) do
    response =
      HTTPoison.post!(
        @files_upload_url,
        {
          :form,
          [
            {"channels", channel},
            {"content", text},
            {"filetype", data[:filetype] || "markdown"},
            {"title", title},
            {"token", token}
          ]
        },
        [
          {"Content-Type", "multipart/form-data"}
        ]
      )

    Poison.decode!(response.body)
  end

  def post_message(text, channel, token) when is_binary(text) do
    post_message(text, "", channel, token)
  end

  def post_message(attachments, channel, token) when is_list(attachments) do
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

  def users_info(%{ user_id: user_id, token: token}) do
    response =
      HTTPoison.get!(
        @users_info_url,
        [],
        params: [
          {:user, user_id},
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

  defp headers(token) do
    [
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer #{token}"}
    ]
  end
end
