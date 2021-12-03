defmodule Todo.Context.Items do
  import Ecto.Query
  alias Todo.Item
  alias Todo.Repo

  @moduledoc """
  Provide functions for create item, update item, get items
  """

  @doc """
  Create the Item

  Example
  iex> create(%{} = valid_params)
  {:ok, item}

  iex> create(%{} = invalid_params)
  {:error, changeset}
  """
  def create(%{} = params) do
    Repo.insert(Item.changeset(%Item{}, params))
  end

  @doc """
  Update the List

  Example
  iex> update(id, %{} = valid_params)
  {:ok, item}

  iex> update(id, %{} = invalid_params)
  {:error, changeset}

  iex> update(invalid_id, %{} = params)
  {:error, changeset}
  """
  def update(id, %{} = params) do
    Item
    |> Repo.get(id)
    |> Item.changeset(params)
    |> Repo.update()
  end

  @doc """
  Show item

  Example
  iex> show(id: id)
  %Item{} || nil
  """
  def show(id: id) do
    Item
    |> where([item], item.id == ^id)
    |> Repo.one()
  end

  @doc """
  Show all items by list_id

  Example
  iex> all_by_list_id(list_id: list_id)
  [] or [item | items]
  """
  def all_by_list_id(list_id: list_id) do
    Item
    |> where([item], item.list_id == ^list_id)
    |> Repo.all()
  end

  @doc """
  Show all items

  Example
  iex> all()
  [] or [item | items]
  """
  def all(), do: Repo.all(Item)
end
