defmodule Absinthe.ConnTest.HTTPTest do
  use ExUnit.Case, async: true

  alias Absinthe.ConnTest.HTTP

  @upload %Plug.Upload{}

  describe "request/2" do
    test "defaults to application/json" do
      assert {_, "application/json"} = HTTP.request("", %{})
    end

    test "extracts an upload" do
      request = HTTP.request("", foo: @upload, bar: @upload)
      assert_upload(request, ["bar"], 0)
      assert_upload(request, ["foo"], 1)
    end

    test "extracts an upload from a list" do
      request = HTTP.request("", items: ["foo", @upload, @upload])
      assert_upload(request, ["items", Access.at(1)], 0)
      assert_upload(request, ["items", Access.at(2)], 1)
    end

    test "extracts uploads from a map" do
      request = HTTP.request("", foo: %{bar: @upload}, buzz: @upload)
      assert_upload(request, ["buzz"], 0)
      assert_upload(request, ["foo", "bar"], 1)
    end

    test "extracts uploads from a deeply nested structure" do
      request = HTTP.request("", foo: [99, %{bar: %{baz: @upload}}], buzz: @upload)
      assert_upload(request, ["buzz"], 0)
      assert_upload(request, ["foo", Access.at(1), "bar", "baz"], 1)
    end
  end

  describe "response/2" do
    test "extracts data" do
      assert HTTP.response(%{"data" => 100}) == {:ok, 100}
    end

    test "extracts errors" do
      response = %{
        "errors" => [
          %{"message" => "foo"},
          %{"message" => "bar"}
        ]
      }

      assert HTTP.response(response) == {:error, ["foo", "bar"]}
    end

    test "extracts errors with extensions" do
      response = %{
        "errors" => [
          %{"message" => "foo"},
          %{"message" => "bar", "extensions" => %{"code" => "buzz"}}
        ]
      }

      assert HTTP.response(response) == {:error, ["foo", {"bar", %{"code" => "buzz"}}]}
    end
  end

  def assert_upload({body, content_type}, path, n) do
    variables = Phoenix.json_library().decode!(body["variables"])

    assert content_type == "multipart/form-data"
    assert body["uploads/#{n}"] == @upload
    assert get_in(variables, path) == "uploads/#{n}"
  end
end
