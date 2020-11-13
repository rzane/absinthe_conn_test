defmodule Absinthe.ConnTest do
  alias Absinthe.ConnTest.HTTP

  @type query :: String.t()
  @type variables :: keyword() | map()

  @spec graphql(Plug.Conn.t(), query(), variables()) :: Macro.t()
  defmacro graphql(conn, query, variables \\ %{}) do
    quote do
      graphql(unquote(conn), @endpoint, @graphql, unquote(query), unquote(variables))
    end
  end

  def graphql(%Plug.Conn{} = conn, endpoint, path, query, variables) when is_binary(query) do
    if is_nil(endpoint), do: raise("no @endpoint set in test case")
    if is_nil(path), do: raise("no @graphql set in test case")

    {body, content_type} = HTTP.request(query, variables)

    conn
    |> Plug.Conn.put_req_header("content-type", content_type)
    |> Phoenix.ConnTest.dispatch(endpoint, :post, path, body)
    |> Phoenix.ConnTest.json_response(200)
    |> HTTP.response()
  end
end
