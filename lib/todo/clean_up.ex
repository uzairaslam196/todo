defmodule Todo.CleanUp do
  use GenServer

  @moduledoc """
  A background cleaner which execute work after each 5 minutes.
  It archived all the lists which are not being updated in last 24 hours.
  """
  alias Todo.Context.Lists

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    # Schedule next run
    schedule_next_run()

    {:ok, state}
  end

  @impl true
  def handle_info(:archive_lists, state) do
    archive_unused_lists()
    schedule_next_run()

    {:noreply, state}
  end

  @impl true
  def handle_cast(:archive_lists, state) do
    Lists.archive_unused()

    {:noreply, state}
  end

  defp schedule_next_run(), do: Process.send_after(self(), :archive_lists, :timer.minutes(5))
  defp archive_unused_lists(), do: GenServer.cast(__MODULE__, :archive_lists)
end
