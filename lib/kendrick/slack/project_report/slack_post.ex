defmodule Kendrick.Slack.ProjectReport.SlackPost do
  import Kendrick.Slack.ProjectReport.Shared, only: [teams: 1]

  alias Kendrick.Users

  def build(project, user) do
    """
    #{header_part(project)}
    #{teams_part(project)}
    #{footer_part(user)}
    """
  end

  defp header_part(project) do
    """
    Hello everybody!
    Below please find the report with the development progress.

    # Questions / Comments
    #{comments_part(project)}\
    """
  end

  defp comments_part(project) do
    comments =
      project
      |> Users.for_project()
      |> Users.with_absence()
      |> Users.all()
      |> Enum.map(&user_absence/1)
      |> Enum.join("\n")

    case comments do
      "" -> "–"
      _ -> comments
    end
  end

  defp user_absence(%{absence: "day_off"} = user), do: "* **#{user.name}** has a day off"
  defp user_absence(%{absence: "sick_leave"} = user), do: "* **#{user.name}** is on a sick leave"
  defp user_absence(%{absence: "vacation"} = user), do: "* **#{user.name}** is on vacation"

  defp teams_part(project) do
    project
    |> teams()
    |> Enum.reduce("", &add_team(&1, &2))
  end

  defp add_team(team, report) do
    users_part = Enum.reduce(team.users, "", &add_user(&1, &2))

    team_part = """

    # #{team.name}
    #{users_part}\
    """

    report <> team_part
  end

  defp add_user(user, report) do
    user_part = """

    ## #{user.name}
    #{tasks_part(user)}
    """

    report <> user_part
  end

  defp tasks_part(%{tasks: []}), do: "No tasks."

  defp tasks_part(user) do
    user.tasks
    |> Enum.with_index(1)
    |> Enum.map(&task_part/1)
    |> Enum.join("\n\n")
  end

  defp task_part({task, index}) do
    [
      "#{index}) #{task.title}",
      task_url(task),
      "Status: #{task.status}"
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join("\n")
  end

  defp task_url(%{url: nil}), do: nil

  defp task_url(%{url: url}) do
    case String.trim(url) do
      "" -> nil
      _ -> url
    end
  end

  defp footer_part(user) do
    """
    Thanks,
    #{user.name}\
    """
  end
end
