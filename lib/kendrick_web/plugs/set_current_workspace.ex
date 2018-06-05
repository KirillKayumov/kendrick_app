defmodule KendrickWeb.Plugs.SetCurrentWorkspace do
  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    %{current_user: current_user} = conn.assigns
    workspace = Kendrick.Workspaces.for_user(current_user)

    assign(conn, :current_workspace, workspace)
  end
end
