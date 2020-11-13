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

## Setup

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

## Testing

A simple test might look something like this:

```elixir
defmodule MyAppWeb.Schema.UsersTest do
  use MyAppWeb.ConnCase

  @say_hello """
  query SayHello($name: String!) {
    hello(name: $name)
  }
  """

  test "hello", %{conn: conn} do
    assert {:ok, %{"hello" => "Hello, Ray!"}} =
            graphql(conn, @say_hello, name: "Ray")
  end
end
```

### Importing queries

Yuck, it's kind of annoying to write your queries in your test file. Let's move
them to dedicated `.graphql` file:

```graphql
# test/fixtures/queries.graphql

query SayHello($name: String!) {
  hello(name: $name)
}
```

Now, you can import those queries, and they'll become test functions!

```elixir
defmodule MyAppWeb.Schema.UsersTest do
  use MyAppWeb.ConnCase

  import_queries "test/fixtures/queries.graphql"

  test "hello", %{conn: conn} do
    assert {:ok, %{"hello" => "Hello, Ray!"}} = say_hello(conn, name: "Ray")
  end
end
```

Note that in the example above the `SayHello` query became a function `say_hello`.

### Errors

Errors are returned in a concise format:

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

### Fragments

Yup, they're supported too. It will also resolve `#import` expressions.

```graphql
# test/fixtures/users.graphql

fragment User on User {
  id
  name
}
```

```graphql
#import "./user.graphql"

query ListUsers {
  users {
    ...User
  }
}
```

### File Uploads

If you attempt to send a [`%Plug.Upload{}`](https://hexdocs.pm/plug/Plug.Upload.html)
to your API, this library will extract it for you in accordance with Absinthe's [file
upload specification](https://hexdocs.pm/absinthe/file-uploads.html).

```graphql
# test/fixtures/queries.graphl

mutation UploadImage($image: Upload!) {
  uploadImage(image: $image)
}
```

```elixir
import_queries "test/fixtures/queries.graphql"

test "uploading an image", %{conn: conn} do
  image = %Plug.Upload{
    filename: "foo.png",
    path: "test/fixtures/image.png"
  }

  assert {:ok, } = upload_image(conn, image: image)
end
```
