defmodule TodoWeb.ListLiveTest do
  use TodoWeb.ConnCase

  @doc """
  Unit tests for TodoWeb.ListLive. They cover mount and each event within live view
  """

  alias TodoWeb.ListLive.Index

  setup do
    list = insert(:list)
    item = insert(:item, list: list)

    archived_list = insert(:list, archived: true)

   %{
     socket: socket(),
     list: list,
     item: item,
     archived_list: archived_list
    }
  end

  test "assign changeset in mount", %{socket: socket} do
    {:ok, socket} = Index.mount(%{}, %{}, socket)

    assert socket.assigns.changeset
  end

  describe "handle events" do
    test "call create list with valid params", %{socket: socket} do
      params = %{"list" => %{"title" => "title"}}
      {:noreply, socket} = Index.handle_event("create", params, socket)

      assert socket.assigns.list
      assert socket.assigns.list.id

      assert "title" == socket.assigns.list.title
      assert false == socket.assigns.list.archived
    end

    test "on list creation, it always set archived false", %{socket: socket} do
      params = %{"list" => %{"title" => "title", "archived" => "true"}}
      {:noreply, socket} = Index.handle_event("create", params, socket)

      assert socket.assigns.list
      assert socket.assigns.list.id

      assert "title" == socket.assigns.list.title
      assert false == socket.assigns.list.archived
    end

    test "it must return error message with blank title", %{socket: socket} do
      {:noreply, socket} = Index.handle_event("create", %{"list" => %{}}, socket)

      assert errors = socket.assigns.changeset.errors
      assert [title: {error_message, _}] = errors
      assert "can't be blank" == error_message
    end

    test "update list with valid params", %{socket: socket, list: list} do
      params = %{"list" => %{"id" => list.id, "title" => "updated title"}}
      {:noreply, socket} = Index.handle_event("update", params, socket)

      assert socket.assigns.list
      assert list.id == socket.assigns.list.id

      assert "updated title" == socket.assigns.list.title
      assert false == socket.assigns.list.archived
    end

    test "with update event, it must not set archived true or false", %{socket: socket, list: list} do
      params = %{"list" => %{"id" => list.id, "archived" => "true"}}
      {:noreply, socket} = Index.handle_event("update", params, socket)

      assert socket.assigns.list
      assert list.id == socket.assigns.list.id
      assert false == socket.assigns.list.archived
    end

    test "archived the list", %{socket: socket, list: list} do
      params = %{"list" => %{"id" => list.id, "archived" => "true"}}
      {:noreply, socket} = Index.handle_event("archived", params, socket)

      assert socket.assigns.list
      assert list.id == socket.assigns.list.id
      assert true == socket.assigns.list.archived
    end

    test "un archived list", %{socket: socket, list: list} do
      params = %{"list" => %{"id" => list.id, "archived" => "false"}}
      {:noreply, socket} = Index.handle_event("archived", params, socket)

      assert socket.assigns.list
      assert list.id == socket.assigns.list.id
      assert false == socket.assigns.list.archived
    end

    test "archived list must not update until gets un archived", %{socket: socket, archived_list: archived_list} do
      params = %{"list" => %{"id" => archived_list.id, "title" => "title"}}
      {:noreply, socket} = Index.handle_event("update", params, socket)

      assert errors = socket.assigns.changeset.errors
      assert [archived: {error_message, []}] = errors
      assert "you need to unarchived it first" == error_message
    end

    test "get all lists", %{socket: socket} do
      {:noreply, socket} = Index.handle_event("list_all", %{}, socket)

      assert [list_1 | _] = lists = socket.assigns.lists
      assert list_1.id
      assert length(lists) == 2
    end

    test "show single list", %{socket: socket, archived_list: archived_list} do
      {:noreply, socket} = Index.handle_event("show_list", %{"id" => archived_list.id}, socket)

      assert socket.assigns.list
      assert socket.assigns.list.id
    end
  end

  defp socket(), do: %Phoenix.LiveView.Socket{}
end
