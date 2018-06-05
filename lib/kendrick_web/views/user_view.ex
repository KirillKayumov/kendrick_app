defmodule KendrickWeb.UserView do
  use KendrickWeb, :view

  def in_app?(slack_user, users) do
    Enum.any?(users, &(&1.slack_id == slack_user["id"]))
  end
end
