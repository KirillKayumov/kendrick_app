defmodule KendrickWeb.Helpers.CurrentResources do
  def current_user(%{assigns: %{current_user: current_user}}), do: current_user

  def current_workspace(%{assigns: %{current_workspace: current_workspace}}),
    do: current_workspace
end
