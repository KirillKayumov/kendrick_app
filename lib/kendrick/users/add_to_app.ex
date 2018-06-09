defmodule Kendrick.Users.AddToApp do
  alias Kendrick.{
    Repo,
    User,
    Workspace
  }

  def call(slack_id, workspace) do
    case Repo.get_by(User, slack_id: slack_id) do
      nil -> create_user(slack_id, workspace)
      user -> user
    end
  end

  defp create_user(slack_id, workspace) do
    %User{}
    |> User.changeset(attributes(slack_id, workspace))
    |> Ecto.Changeset.put_assoc(:workspace, workspace)
    |> Repo.insert!()
  end

  defp attributes(slack_id, workspace) do
    slack_user = Enum.find(workspace.slack_users["list"], &(&1["id"] == slack_id))

    %{
      slack_id: slack_user["id"],
      name: slack_user["real_name"]
    }
  end
end
