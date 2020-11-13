defmodule Absinthe.ConnTestTest do
  use ExUnit.Case

  import Absinthe.ConnTest

  alias Absinthe.ConnTest.Test.Endpoint

  @endpoint Endpoint
  @graphql "/graphql"

  import_queries "test/fixtures/example.graphql"

  setup do
    start_supervised!(Endpoint)
    [conn: Phoenix.ConnTest.build_conn()]
  end

  test "hello/1", %{conn: conn} do
    assert {:ok, %{"hello" => "Hello, world!"}} = hello(conn)
  end

  test "hello/2", %{conn: conn} do
    assert {:ok, %{"hello" => "Hello, Ray!"}} = hello(conn, name: "Ray")
  end

  test "create_profile/2", %{conn: conn} do
    data = %{
      name: "Rick",
      image: %Plug.Upload{filename: "profile.png"}
    }

    assert {:ok, %{"profile" => profile}} = create_profile(conn, data: data)
    assert profile["name"] == "Rick"
    assert profile["image"]["filename"] == "profile.png"
  end

  test "create_profile/2 with error", %{conn: conn} do
    assert {:error, ["Name can't be blank"]} = create_profile(conn, data: %{name: ""})
  end
end
