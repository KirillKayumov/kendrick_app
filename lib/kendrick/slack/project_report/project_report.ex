defmodule Kendrick.Slack.ProjectReport do
  alias Kendrick.{
    Repo,
    Slack,
    Task,
    User
  }

  import Ecto.Query

  def build(project) do
    project
    |> teams()
    |> Enum.reduce([], &add_team(&1, &2, project))
  end

  defp teams(project) do
    tasks = Task |> order_by(:id)
    users = User |> preload(tasks: ^tasks) |> order_by(:id)

    project
    |> Ecto.assoc(:teams)
    |> preload(users: ^users)
    |> order_by(:id)
    |> Repo.all()
  end

  defp add_team(team, attachments, project) do
    attachments =
      attachments ++
        [
          %{
            color: "#FFFFFF",
            fallback: team.name,
            title: String.upcase(team.name)
          }
        ]

    Enum.reduce(team.users, attachments, &add_user(&1, &2, project))
  end

  defp add_user(user, attachments, project) do
    attachments =
      attachments ++
        [
          %{
            color: "#717171",
            fallback: user.name,
            title: user.name
          }
        ]

    attachments ++ Slack.Report.Tasks.build(user.tasks, %{project: project})
  end
end
