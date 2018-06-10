defmodule KendrickWeb.TeamController do
  use KendrickWeb, :controller

  alias Kendrick.{
    Projects,
    Team,
    Teams,
    Users
  }

  plug(:set_project)
  plug(:set_team, only: [:show, :update, :delete])

  def show(conn, _params) do
    %{team: team} = conn.assigns

    user_ids =
      team
      |> Users.for_team()
      |> Enum.map(& &1.id)

    conn
    |> assign(:users, Users.for_workspace(current_workspace(conn)))
    |> assign(:team_user_ids, user_ids)
    |> assign(:changeset, Team.changeset(team))
    |> render("show.html")
  end

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

  def update(conn, %{"team" => team_params}) do
    %{project: project, team: team} = conn.assigns
    Teams.update(team, team_params, current_workspace(conn))

    conn
    |> redirect(to: project_team_path(conn, :show, project, team))
  end

  def delete(conn, _params) do
    %{project: project, team: team} = conn.assigns
    Teams.delete!(team)

    conn
    |> redirect(to: project_path(conn, :show, project))
  end

  defp set_project(%{params: %{"project_id" => project_id}} = conn, _opts) do
    assign(conn, :project, Projects.get(project_id))
  end

  defp set_team(%{params: %{"id" => id}} = conn, _opts) do
    assign(conn, :team, Teams.get(id))
  end
end
