defmodule Todo.Context.Lists do
  import Ecto.Query
  alias Todo.List
  alias Todo.Repo

  @moduledoc """
  Provide functions for create list, update list, get lists
  """

  @doc """
  Create the list

  Example
  iex> list(%{} = valid_params)
  {:ok, list}

  iex> create(%{} = invalid_params)
  {:error, changeset}
  """
  def create(%{} = params) do
    Repo.insert(List.changeset(%List{}, params))
  end

  @doc """
  Update the List

  Example
  iex> update(id, %{} = valid_params)
  {:ok, item}

  iex> update(id, %{} = invalid_params)
  {:error, changeset}
  """

  def update(id,  %{} = params) do
    List
    |> Repo.get(id)
    |> List.changeset(params)
    |> Repo.update()
  end

  @doc """
  Show item with preloaded items

  Example
  iex> show(id: id)
  %List{} || nil
  """

  def show(id: id) do
    List
    |> where([list], list.id == ^id)
    |> preload([:items])
    |> Repo.one()
  end

  @doc """
  Show all lists

  Example
  iex> all()
  [] or [list | lists]
  """

  def all() do
    List
    |> preload([:items])
    |> Repo.all()
  end

  @doc """
  archived all the lists which are not updated in previos 24 hours.
  It archived all the lists in which no single item is being inserted or updated nor even list record is updated.
  """

  def archive_unused() do
    time_limit = NaiveDateTime.add(NaiveDateTime.utc_now(), -86400)

    list_ids =
      from(list in List,
      left_join: item in assoc(list, :items),
      where: list.archived == false and (item.updated_at > ^time_limit or list.updated_at > ^time_limit),
      select: list.id
      )
      |> Repo.all()

    from(
      list in List,
      where: list.archived == false and list.id not in ^list_ids,
      update: [set: [archived: true, updated_at: ^NaiveDateTime.utc_now()]]
    )
    |> Repo.update_all([])
  end
end
