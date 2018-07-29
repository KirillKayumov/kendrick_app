defmodule Kendrick.Slack.ProjectReport do
  import Kendrick.Slack.ProjectReport.Shared, only: [teams: 1]
  import Kendrick.Slack.Report.Shared, only: [absence_reasons: 0]
  import Kendrick.Slack.Shared, only: [encode_callback_id: 1]

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
        user_name_attachment(user, project)
      ] ++ Slack.ProjectReport.UserTasks.build(user, project)
  end

  defp user_name_attachment(user, project) do
    %{
      actions: Slack.Report.Menu.menu_actions(%{project: project}),
      callback_id: callback_id(user, project),
      color: user.color,
      fallback: user_name(user),
      title: user_name(user)
    }
  end

  defp user_name(%{absence: nil} = user), do: String.upcase(user.name)

  defp user_name(user), do: "#{String.upcase(user.name)} (#{absence_reasons()[user.absence]})"

  defp callback_id(user, project), do: encode_callback_id(%{user_id: user.id, project_id: project.id})

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
