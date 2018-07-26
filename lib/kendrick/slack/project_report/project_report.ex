defmodule Kendrick.Slack.ProjectReport do
  import Kendrick.Slack.ProjectReport.Shared, only: [teams: 1]

  alias Kendrick.Slack
  alias Slack.ProjectReport.Menu

  def build(project) do
    []
    |> add_tasks(project)
    |> add_menu(project)
  end

  defp add_tasks(attachments, project) do
    tasks =
      project
      |> teams()
      |> Enum.reduce([], &add_team(&1, &2, project))

    attachments ++ tasks
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

  defp add_menu(attachments, project) do
    attachments ++ [Menu.build(project)]
  end
end
