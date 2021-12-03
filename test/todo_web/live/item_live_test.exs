defmodule TodoWeb.ItemLiveTest do
  use TodoWeb.ConnCase

  @doc """
  Unit tests for TodoWeb.ItemLive. They cover mount and each event within live view
  """

  alias TodoWeb.ItemLive.Index

  setup do
    list = insert(:list)
    item = insert(:item, list: list)

    archived_list = insert(:list, archived: true)
    archived_list_item = insert(:item, list: archived_list)

   %{
     socket: socket(),
     list: list,
     item: item,
     archived_list: archived_list,
     archived_list_item: Todo.Repo.preload(archived_list_item, :list)
    }
  end

  test "assign changeset in mount", %{socket: socket} do
    {:ok, socket} = Index.mount(%{}, %{}, socket)

    assert socket.assigns.changeset
  end

  describe "handle events" do
    test "call create item with valid params", %{socket: socket, list: list} do
      params = %{"item" => %{"content" => "content", "list_id" => list.id}}
      {:noreply, socket} = Index.handle_event("create", params, socket)

      assert socket.assigns.item
      assert socket.assigns.item.id
      assert list.id == socket.assigns.item.list_id

      assert "content" == socket.assigns.item.content
      assert false == socket.assigns.item.completed
    end

    test "on item creation, it always set completed false", %{socket: socket, list: list} do
      params = %{"item" => %{"content" => "content", "completed" => "true", "list_id" => list.id}}
      {:noreply, socket} = Index.handle_event("create", params, socket)

      assert socket.assigns.item
      assert socket.assigns.item.id
      assert list.id == socket.assigns.item.list_id

      assert "content" == socket.assigns.item.content
      assert false == socket.assigns.item.completed
    end
    @tag :current
    test "it must return error message with blank content", %{socket: socket} do
      {:noreply, socket} = Index.handle_event("create", %{"item" => %{}}, socket)

      assert errors = socket.assigns.changeset.errors
      assert [content: {error_message, _}, list_id: {error_message, _}] = errors
      assert "can't be blank" == error_message
    end

    test "update item with valid params", %{socket: socket, item: item} do
      params = %{"item" => %{"id" => item.id, "content" => "updated content"}}
      {:noreply, socket} = Index.handle_event("update", params, socket)

      assert socket.assigns.item
      assert item.id == socket.assigns.item.id

      assert "updated content" == socket.assigns.item.content
      assert false == socket.assigns.item.completed
    end

    test "with update event, it must not set completed true or false", %{socket: socket, item: item} do
      params = %{"item" => %{"id" => item.id, "completed" => "true"}}
      {:noreply, socket} = Index.handle_event("update", params, socket)

      assert socket.assigns.item
      assert item.id == socket.assigns.item.id
      assert false == socket.assigns.item.completed
    end

    test "completed the item", %{socket: socket, item: item} do
      params = %{"item" => %{"id" => item.id, "completed" => "true"}}
      {:noreply, socket} = Index.handle_event("completed", params, socket)

      assert socket.assigns.item
      assert item.id == socket.assigns.item.id
      assert true == socket.assigns.item.completed
    end

    test "un completed item", %{socket: socket, item: item} do
      params = %{"item" => %{"id" => item.id, "completed" => "false"}}
      {:noreply, socket} = Index.handle_event("completed", params, socket)

      assert socket.assigns.item
      assert item.id == socket.assigns.item.id
      assert false == socket.assigns.item.completed
    end

    test "new item can't be created in archived list",
    %{socket: socket, archived_list: archived_list} do

      params = %{"item" => %{"list_id" => archived_list.id, "content" => "content"}}
      {:noreply, socket} = Index.handle_event("create", params, socket)

      assert errors = socket.assigns.changeset.errors
      assert [list_id: {error_message, []}] = errors
      assert "can't create item in archive list" == error_message
    end

    test "archived list item must not update until its list gets un archived",
    %{socket: socket, archived_list_item: archived_list_item} do
      params = %{"item" => %{"id" => archived_list_item.id, "content" => "content"}}
      {:noreply, socket} = Index.handle_event("update", params, socket)

      assert errors = socket.assigns.changeset.errors
      assert [list_id: {error_message, []}] = errors
      assert "can't update archive item list" == error_message
    end

    test "archived list item complete or un complete until its list gets un archived",
    %{socket: socket, archived_list_item: archived_list_item} do
      params = %{"item" => %{"id" => archived_list_item.id, "complete" => "true"}}
      {:noreply, socket} = Index.handle_event("update", params, socket)

      assert errors = socket.assigns.changeset.errors
      assert [list_id: {error_message, []}] = errors
      assert "can't update archive item list" == error_message
    end

    test "can't move item to archive list",
    %{socket: socket, archived_list: archived_list, item: item} do
      params = %{"item" => %{"id" => item.id, "list_id" => archived_list.id}}
      {:noreply, socket} = Index.handle_event("update", params, socket)

      assert errors = socket.assigns.changeset.errors
      assert [list_id: {error_message, []}] = errors
      assert "can't move to archive list" == error_message
    end

    test "get all itmes by list_id", %{socket: socket, list: list} do
      {:noreply, socket} = Index.handle_event("list_items", %{"list_id" => list.id}, socket)

      assert [item_1 | _] = items = socket.assigns.items
      assert item_1.id
      assert length(items) == 1
    end

    test "show single item by id", %{socket: socket, item: item} do
      {:noreply, socket} = Index.handle_event("show_item", %{"id" => item.id}, socket)

      assert socket.assigns.item
      assert socket.assigns.item.id
    end
  end

  defp socket(), do: %Phoenix.LiveView.Socket{}
end
