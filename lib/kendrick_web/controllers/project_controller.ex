defmodule KendrickWeb.ProjectController do
  use KendrickWeb, :controller

  alias Kendrick.{
    Project,
    Projects,
    Teams
  }

  def index(conn, _params) do
    projects = Projects.for_workspace(current_workspace(conn))

    conn
    |> render("index.html", projects: projects)
  end

  def show(conn, %{"id" => id}) do
    project = Projects.get(id)
    teams = Teams.for_project(project)

    conn
    |> assign(:project, project)
    |> assign(:teams, teams)
    |> render("show.html", team: teams)
  end

  def new(conn, _params) do
    conn
    |> render("new.html", changeset: Project.changeset(%Project{}))
  end

  def create(conn, %{"project" => project_params}) do
    case Projects.create(project_params, current_workspace(conn)) do
      {:ok, _} ->
        conn
        |> redirect(to: project_path(conn, :index))

      {:error, changeset} ->
        conn
        |> render("new.html", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    Projects.delete(id)

    conn
    |> redirect(to: project_path(conn, :index))
  end
end
