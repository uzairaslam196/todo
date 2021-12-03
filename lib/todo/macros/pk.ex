defmodule Todo.PK do
  defmacro __using__(_) do
    quote do
      @timestamps_opts [type: :naive_datetime_usec]
      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id
    end
  end
end
