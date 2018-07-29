defmodule Kendrick.Users.Colors do
  import Ecto.Query

  alias Kendrick.Repo

  @colors [
    "#003A48", "#017692", "#01AEA8", "#193D5A", "#199AA8", "#39000D", "#472A5E", "#60BE98", "#760000", "#80B09A",
    "#8A1E42", "#930000", "#A6E0B9", "#AAD356", "#AD3A59", "#B51B05", "#B7E1F3", "#C10000", "#C44165", "#C8C9A7",
    "#DA8F00", "#DAC196", "#E04118", "#E05400", "#F45844", "#F88600", "#F9CA09", "#FEC101", "#FF4062", "#FF9C98"
  ]

  def unique_for_workspace(workspace) do
    free_colors =
      case @colors -- picked_colors do
        [] -> @colors
        free_colors -> free_colors
      end

    Enum.random(free_colors)
  end

  defp picked_colors(workspace) do
    workspace
    |> Ecto.assoc(:users)
    |> select([u], u.color)
    |> Repo.all()
  end
end
