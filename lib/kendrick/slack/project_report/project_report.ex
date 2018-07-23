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
          delimiter(),
          %{
            fallback: team.name,
            title: String.upcase(team.name),
            color: "#717171"
          }
        ]

    Enum.reduce(team.users, attachments, &add_user(&1, &2, project))
  end

  defp add_user(user, attachments, project) do
    attachments ++
      [
        delimiter(),
        user_name(user),
        delimiter()
      ] ++
      Slack.Report.Tasks.build(user.tasks, %{project: project}) ++ [Slack.Report.Menu.build(user, %{project: project})]
  end

  defp user_name(user) do
    %{
      fallback: user.name,
      title: String.upcase(user.name),
      color: "#A4A4A4"
    }
  end

  defp delimiter do
    %{
      fallback: "",
      title: ""
    }
  end
end
