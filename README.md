# Absinthe.ConnTest

This package makes it really convenient to execute GraphQL queries and mutations
against your Phoenix Endpoint.

Executing queries as HTTP requests helps to ensure that your application behaves
the same way under test as it does under normal circumstances.

## Installation

The package can be installed by adding `absinthe_conn_test` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:absinthe_conn_test, "~> 0.1.0"}
  ]
end
```

## Usage

You'll probably want to import this module in your `ConnCase`.

```elixir
# test/support/conn_case.ex

defmodule MyAppWeb.ConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      # ...etc, etc

      # Import this library
      import Absinthe.ConnTest

      # The default endpoint for testing
      @endpoint MyAppWeb.Endpoint

      # The default URL for your GraphQL API
      @graphql "/graphql"
    end
  end

  # ... etc, etc
end
```

Great, now you're ready to test!

```elixir
test "hello world", %{conn: conn} do
  assert {:ok, %{"hello" => "Hello, world!"}} = graphql(conn, "query { hello }")
end
```

### Importing Queries

First, create a query in a file:

```graphql
# assets/src/queries/users.graphql

query GetUser($id: ID!) {
  user(id: $id) {
    id
    name
  }
}
```

Now, you can simply import these queries, which will convert them to test functions!

```elixir
defmodule MyAppWeb.Schema.UsersTest do
  use MyAppWeb.ConnCase

  import_queries "assets/src/queries/users.graphql"

  test "returns a user", %{conn: conn} do
    user = Users.insert_user(%{name: "Sally"})

    assert {:ok, data} = get_user(conn, id: user.id)
    assert data["user"]["name"] == "Sally"
  end
end
```

### Errors

Here's how you'd test an error:

```elixir
test "produces an error message", %{conn: conn} do
  assert {:error, ["is invalid"]} = create_user(conn, data: %{})
end
```

If your error contains extensions, it'll look like this:

```elixir
test "produces an error message with extensions", %{conn: conn} do
  assert {:error, [{"is invalid", %{"code" => "VALIDATION_ERROR"}}]} =
           create_user(conn, data: %{})
end
```
