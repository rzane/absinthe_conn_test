defmodule Absinthe.ConnTest.LoaderTest do
  use ExUnit.Case, async: true

  alias Absinthe.ConnTest.Loader
  alias Absinthe.ConnTest.Loader.Error

  @foo "fragment Foo on Foo { id bar { ...Bar } }"
  @bar "fragment Bar on Bar { id }"
  @get_foo "query GetFoo { foo { ...Foo } }"

  test "loads a query" do
    [foo, get, bar] = Loader.load!("test/fixtures/queries.graphql")

    assert foo.name == "Foo"
    assert foo.needs == ["Bar"]
    assert strip(foo.source) == @foo

    assert get.name == "GetFoo"
    assert get.needs == ["Foo"]
    assert strip(get.source) == @get_foo

    assert bar.name == "Bar"
    assert bar.needs == []
    assert strip(bar.source) == @bar
  end

  test "loads a ridiculous oneliner" do
    [foo, get, bar] = Loader.load!("test/fixtures/oneliner.graphql")

    assert foo.name == "Foo"
    assert strip(foo.source) == @foo

    assert get.name == "GetFoo"
    assert strip(get.source) == @get_foo

    assert bar.name == "Bar"
    assert strip(bar.source) == @bar
  end

  test "resolving dependencies" do
    queries = Loader.load!("test/fixtures/queries.graphql")
    [get] = Loader.resolve(queries)

    assert get.name == "GetFoo"
    assert get.needs == []
    assert strip(get.source) == Enum.join([@bar, @foo, @get_foo], " ")
  end

  test "raises an error for an invalid query" do
    path = "test/fixtures/errors/invalid.graphql"
    message = "syntax error before: \"There\" (#{path}:1)"
    assert_raise Error, message, fn -> Loader.load!(path) end
  end

  test "raises an error for a missing fragment" do
    queries = Loader.load!("test/fixtures/errors/fragment-not-found.graphql")

    assert_raise Error, ~r/Fragment 'Foo' does not exist/, fn ->
      Loader.resolve(queries)
    end
  end

  test "expands imports" do
    queries = Loader.load!("test/fixtures/imports/queries.graphql")
    assert Enum.map(queries, & &1.name) == ["Bar", "Foo", "GetFoo"]
  end

  defp strip(text) do
    text
    |> String.replace(~r/\s+/, " ")
    |> String.trim()
  end
end
