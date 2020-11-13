defmodule Absinthe.ConnTest do
  @moduledoc """
  Conveniences for testing GraphQL APIs.

  You'll probably want to import this module in your `ConnCase`.
  """

  alias Absinthe.ConnTest.HTTP
  alias Absinthe.ConnTest.Loader
  alias Absinthe.ConnTest.Loader.Query

  @type query :: String.t()
  @type variables :: keyword() | map()
  @type error :: String.t() | {String.t(), map()}
  @type response :: {:ok, term()} | {:error, [error()]}

  @doc """
  Execute a query against the configured `@endpoint` and `@graphql` path.
  """
  @spec graphql(Plug.Conn.t(), query(), variables()) :: Macro.t()
  defmacro graphql(conn, query, variables \\ %{}) do
    quote do
      graphql(unquote(conn), @endpoint, @graphql, unquote(query), unquote(variables))
    end
  end

  @spec graphql(Plug.Conn.t(), term(), String.t(), query(), variables()) :: response()
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

  @doc """
  Import queries from a file and convert them to test functions.
  """
  @spec import_queries(Path.t()) :: Macro.t()
  defmacro import_queries(path) do
    queries =
      path
      |> Loader.load!()
      |> Loader.resolve()

    for %Query{name: query_name, type: type, source: query} <- queries do
      name = query_name |> Macro.underscore() |> String.to_atom()

      quote do
        @doc """
        Executes the `#{unquote(query_name)}` #{unquote(type)}:

        ```graphql
        #{unquote(query)}
        ```
        """
        @spec unquote(name)(Plug.Conn.t(), Absinthe.ConnTest.variables()) ::
                Absinthe.ConnTest.response()
        def unquote(name)(conn, variables \\ %{}) do
          graphql(conn, unquote(query), variables)
        end
      end
    end
  end
end
