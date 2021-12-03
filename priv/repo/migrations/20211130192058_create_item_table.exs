defmodule Todo.Repo.Migrations.CreateItemTable do
  use Ecto.Migration

  def change do
    create table(:items, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :content, :string
      add :completed, :boolean, default: false
      add :list_id, references(:lists, column: :id, type: :uuid), null: false

      timestamps()
    end
  end
end
