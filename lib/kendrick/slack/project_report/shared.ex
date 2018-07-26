defmodule Kendrick.Slack.ProjectReport.Shared do
  import Ecto.Query

  alias Kendrick.{
    Repo,
    Task,
    User
  }

  def teams(project) do
    tasks = Task |> order_by(:id)
    users = User |> preload(tasks: ^tasks) |> order_by(:id)

    project
    |> Ecto.assoc(:teams)
    |> preload(users: ^users)
    |> order_by(:id)
    |> Repo.all()
  end
end
