defmodule Todo.Item do
  use Todo.Schema, :model
  use Todo.PK

  @moduledoc """
  Schema for Item. It cast and validate the fields
  """

  alias Todo.List
  alias Todo.Item
  alias Todo.Repo

  schema "items" do
    field :content, :string
    field :completed, :boolean, default: false
    belongs_to :list, Todo.List, foreign_key: :list_id, references: :id

    timestamps()
  end

  @doc false
  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, [:content, :completed, :list_id])
    |> validate_required([:content, :list_id])
    |> foreign_key_constraint(:list_id)
    |> validate_archive(struct)
  end

  defp validate_archive(%{changes: %{list_id: list_id_2}} = changeset, %Item{list_id: nil}) do
    changeset
    |> validate(list_id: list_id_2)
    |> return("can't create item in archive list")
  end

  defp validate_archive(%{changes: %{list_id: list_id_2}} = changeset, %Item{list_id: list_id}) do
    changeset
    |> validate(list_id: list_id)
    |> validate(list_id: list_id_2)
    |> return("can't move to archive list")
  end

  defp validate_archive(changeset, %Item{list_id: nil}), do: changeset

  defp validate_archive(changeset, %Item{list_id: list_id}) do
    changeset
    |> validate(list_id: list_id)
    |> return("can't update archive item list")
  end

  defp validate({:error, changeset}, _), do: add_error(changeset, :list_id, "can't update archive item list")
  defp validate(changeset, list_id: list_id), do: validate(Repo.get(List, list_id), changeset)

  defp validate(%List{archived: true}, changeset), do: {:error, changeset}
  defp validate(_, changeset), do: changeset

  defp return({:error, changeset}, message), do: add_error(changeset, :list_id, message)
  defp return(changeset, _), do: changeset

end
