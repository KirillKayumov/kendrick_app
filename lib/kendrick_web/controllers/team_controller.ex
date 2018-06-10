defmodule KendrickWeb.TeamController do
  use KendrickWeb, :controller

  alias Kendrick.{
    Projects,
    Team,
    Teams
  }

  plug(:set_project)

  def new(conn, _params) do
    conn
    |> render("new.html", changeset: Team.changeset(%Team{}))
  end

  def create(conn, %{"team" => team_params}) do
    %{project: project} = conn.assigns
    result = Teams.create(team_params, project)

    case result do
      {:ok, _} ->
        conn
        |> redirect(to: project_path(conn, :show, project))

      {:error, changeset} ->
        conn
        |> render("new.html", changeset: changeset)
    end
  end

  defp set_project(%{params: %{"project_id" => project_id}} = conn, _opts) do
    assign(conn, :project, Projects.get(project_id))
  end
end
