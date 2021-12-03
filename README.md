# Todo

Todo is build to create todo lists. Users can create lists and manage items within them.
There is a background process which archived all the lists which are not being updated in last 24 hours.


Todo runs on Elixir 1.12.2 and OTP 24.0 with Postgresql

To run Todo, first clone the repository. 

```
git clone git@github.com:uzairaslam-coder/todo.git
```

Change directory into the new todo folder.

```
cd todo
```

Retrieve the dependencies and compile from the root directory with mix.

```
mix deps.get
mix compile
```


Create and migrate your database with `mix ecto.setup`

To start your Phoenix server:
Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

To run test cases

 * To run all test cases, use 
    `mix test`
 * To run test cases for individual module `mix test` by following relative file_path. Example
    > For ItemLive View test cases
      `mix test test/todo_web/live/item_live_test.exs`

    > For ListLive View test cases
      `mix test test/todo_web/live/list_live_test.exs`


