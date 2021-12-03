defmodule TodoWeb.ListLive.Index do
  use TodoWeb, :live_view

  alias Todo.Context.Lists
  alias Todo.List

  @impl true
  def mount(_params, _session, socket) do

    changeset = List.changeset(%List{}, %{})

    {:ok, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("create", %{"list" => list}, socket) do
     {_, list} = Map.pop(list, "archived")

    socket =
      case Lists.create(list) do
      {:ok, list} ->
        socket
        |> assign(:list, list)
      {:error, changeset} ->
        assign(socket, :changeset, changeset)
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("update", %{"list" => %{"id" => id} = params}, socket) do
   {_, params} = Map.pop(params, "archived")

    socket =
      case Lists.update(id, params) do
      {:ok, list} ->
        socket
        |> assign(:list, list)
      {:error, changeset} ->
        assign(socket, :changeset, changeset)
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("archived", %{"list" => %{"id" => id, "archived" => _} = params}, socket) do
    socket =
      case Lists.update(id, params) do
      {:ok, list} ->
        socket
        |> assign(:list, list)
      {:error, changeset} ->
        assign(socket, :changeset, changeset)
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("list_all", _, socket) do
     lists = Lists.all()

    {:noreply, assign(socket, :lists, lists)}
  end

  @impl true
  def handle_event("show_list", %{"id" => id}, socket) do
     item = Lists.show(id: id)

    {:noreply, assign(socket, :list, item)}
  end
end
