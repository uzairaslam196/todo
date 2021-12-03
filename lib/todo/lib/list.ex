defmodule Todo.List do
  use Todo.Schema, :model
  use Todo.PK

  @moduledoc """
  Schema for List. It cast and validate the fields
  """

  alias Todo.List
  alias Todo.List

  schema "lists" do
    field :title, :string
    field :archived, :boolean, default: false
    has_many :items, Todo.Item

    timestamps()
  end

  @doc false
  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, [:title, :archived])
    |> validate_required([:title])
    |> validate_archive(struct)
  end

  def validate_archive(%{changes: %{archived: false}} = changeset, %List{archived: true}), do: changeset

  def validate_archive(changeset, %List{archived: true}) do
    add_error(changeset, :archived, "you need to unarchived it first")
  end

  def validate_archive(changeset, _), do: changeset
end
