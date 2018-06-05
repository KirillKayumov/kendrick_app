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
    |> User.changeset(%{slack_id: slack_id})
    |> Ecto.Changeset.put_assoc(:workspace, workspace)
    |> Repo.insert!()
  end
end
