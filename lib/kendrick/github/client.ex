defmodule Kendrick.Github.Client do
  @token System.get_env("GITHUB_TOKEN")
  @headers [{"Authorization", "token #{@token}"}]

  @pull_request_url "https://api.github.com/repos/:owner/:repo/pulls/:id"

  def pull_request(%{owner: owner, repo: repo, id: id}) do
    url =
      @pull_request_url
      |> String.replace(":owner", owner)
      |> String.replace(":repo", repo)
      |> String.replace(":id", id)

    response = HTTPoison.get!(url, @headers)

    Poison.decode!(response.body)
  end
end
