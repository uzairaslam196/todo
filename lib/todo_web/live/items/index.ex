defmodule TodoWeb.ItemLive.Index do
  use TodoWeb, :live_view

  alias Todo.Context.Items
  alias Todo.Item

  @impl true
  def mount(_params, _session, socket) do

    changeset = Item.changeset(%Item{}, %{})

    {:ok, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("create", %{"item" => item}, socket) do
    {_, item} = Map.pop(item, "completed")
    socket =
      case Items.create(item) do
      {:ok, item} ->
        socket
        |> assign(:item, item)
      {:error, changeset} ->
        assign(socket, :changeset, changeset)
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("update", %{"item" => %{"id" => id} = params}, socket) do
   {_, params} = Map.pop(params, "completed")
    socket =
      case Items.update(id, params) do
      {:ok, item} ->
        socket
        |> assign(:item, item)
      {:error, changeset} ->
        assign(socket, :changeset, changeset)
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("completed", %{"item" => %{"id" => id, "completed" => _} = params}, socket) do
    socket =
      case Items.update(id, params) do
      {:ok, item} ->
        socket
        |> assign(:item, item)
      {:error, changeset} ->
        assign(socket, :changeset, changeset)
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("list_items", %{"list_id" => list_id}, socket) do
     items = Items.all_by_list_id(list_id: list_id)

    {:noreply, assign(socket, :items, items)}
  end

  @impl true
  def handle_event("show_item", %{"id" => id}, socket) do
     item = Items.show(id: id)

    {:noreply, assign(socket, :item, item)}
  end
end
