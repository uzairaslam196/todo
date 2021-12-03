defmodule Todo.Repo.Migrations.CreateListTable do
  use Ecto.Migration

  def change do
    create table(:lists, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :title, :string
      add :archived, :boolean, default: false

      timestamps()
    end
  end
end
