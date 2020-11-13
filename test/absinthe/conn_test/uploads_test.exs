defmodule Absinthe.ConnTest.UploadsTest do
  use ExUnit.Case, async: true

  alias Absinthe.ConnTest.Uploads

  @upload %Plug.Upload{}
  @key "uploads/0"

  test "extracts an upload" do
    assert Uploads.extract(@upload) == {@key, %{@key => @upload}, 1}
  end

  test "extracts from a map" do
    assert Uploads.extract(%{foo: @upload}) == {%{foo: @key}, %{@key => @upload}, 1}
  end

  test "extracts from a list" do
    assert Uploads.extract([@upload]) == {[@key], %{@key => @upload}, 1}
  end

  test "reports when no results are found" do
    assert {1, %{}, 0} = Uploads.extract(1)
  end

  test "extracts from a really deeply nested structure" do
    variables = %{foo: %{bar: [%{jawn: @upload, baz: [%{quuz: @upload}]}]}}

    assert Uploads.extract(variables) == {
             %{foo: %{bar: [%{baz: [%{quuz: "uploads/0"}], jawn: "uploads/1"}]}},
             %{"uploads/0" => @upload, "uploads/1" => @upload},
             2
           }
  end
end
