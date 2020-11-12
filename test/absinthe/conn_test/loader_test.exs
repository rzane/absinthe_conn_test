defmodule Absinthe.ConnTest.LoaderTest do
  use ExUnit.Case, async: true

  alias Absinthe.ConnTest.Loader

  @get_foo """
  fragment Foo on Foo {
    id
  }

  query GetFoo {
    id
    query
    mutation
    foo {
      ...Foo
    }
  }

  """

  @create_foo """
  fragment Foo on Foo {
    id
  }

  mutation CreateFoo {
    createFoo {
      ...Foo
    }
  }
  """

  test "loads a query" do
    queries = Loader.load("test/fixtures/queries.graphql")
    assert Map.keys(queries) == ["CreateFoo", "Foo", "GetFoo"]
    assert queries["GetFoo"] == @get_foo
    assert queries["CreateFoo"] == @create_foo
  end
end
