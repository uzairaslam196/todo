defmodule Todo.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: Todo.Repo

  alias Todo.{List, Item}

  def list_factory do
    %List{
      title: sequence(:titles, &"test list #{&1}"),
    }
  end

  def item_factory do
    %Item{
      content: sequence(:contents, &"test content #{&1}"),
    }
  end
end
