defmodule Kendrick.Slack.ProjectReport.Shared do
  import Ecto.Query

  alias Kendrick.{
    Repo,
    Task,
    User
  }

  def title do
    today = Date.utc_today()
    month = Timex.format!(today, "%B", :strftime)
    day = Cldr.Number.to_string!(today.day, format: :ordinal)

    "DAILY REPORT: #{month} #{day}"
  end

  def teams(project) do
    tasks = Task |> where(disabled: false) |> order_by(:id)
    users = User |> preload(tasks: ^tasks) |> order_by(:id)

    project
    |> Ecto.assoc(:teams)
    |> preload(users: ^users)
    |> order_by(:id)
    |> Repo.all()
  end
end
