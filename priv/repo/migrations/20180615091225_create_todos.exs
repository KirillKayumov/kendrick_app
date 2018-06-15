defmodule Kendrick.Repo.Migrations.CreateTodos do
  use Ecto.Migration

  def change do
    create table(:todos) do
      add(:text, :string, null: false)
      add(:completed, :boolean, null: false, default: false)

      add(:user_id, references(:users), null: false)
      add(:project_id, references(:projects), null: false)

      timestamps()
    end

    create(index(:todos, :user_id))
    create(index(:todos, :project_id))
  end
end
