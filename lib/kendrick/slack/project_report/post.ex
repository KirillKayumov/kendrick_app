defmodule Kendrick.Slack.ProjectReport.Post do
  import Kendrick.Slack.ProjectReport.Shared, only: [teams: 1]

  def build(project) do
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
    tasks_part =
      user.tasks
      |> Enum.with_index(1)
      |> Enum.reduce("", &add_task(&1, &2))

    user_part = """
    ## #{user.name}
    #{tasks_part}\
    """

    report <> user_part
  end

  defp add_task({task, index}, report) do
    task_part =
      [
        "#{index}) #{task.title}",
        task_url(task),
        "Status: #{task.status}",
        "\n"
      ]
      |> Enum.reject(&is_nil/1)
      |> Enum.join("\n")

    report <> task_part
  end

  defp task_url(%{url: nil}), do: nil

  defp task_url(%{url: url}) do
    case String.trim(url) do
      "" -> nil
      _ -> url
    end
  end
end
