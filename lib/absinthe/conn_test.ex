defmodule Absinthe.ConnTest do
  alias Absinthe.ConnTest.Uploads

  defmacro __using__(opts \\ []) do
    path = Keyword.get(opts, :path, "/graphql")

    quote do
      import Absinthe.ConnTest

      def graphql(conn, query, variables \\ %{}) do
        graphql(conn, @endpoint, unquote(path), query, variables)
      end
    end
  end

  def graphql(conn, endpoint, path, query, variables) do
    {body, content_type} = build_request(query, variables)

    conn
    |> Plug.Conn.put_req_header("content-type", content_type)
    |> Phoenix.ConnTest.dispatch(endpoint, :post, path, body)
    |> Phoenix.ConnTest.json_response(200)
    |> build_response()
  end

  defp build_request(query, variables) when is_list(variables) do
    build_request(query, Map.new(variables))
  end

  defp build_request(query, variables) when is_map(variables) do
    {variables, uploads, count} = Uploads.extract(variables)
    {serialize(query, variables, uploads), get_content_type(count)}
  end

  defp get_content_type(0), do: "application/json"
  defp get_content_type(_), do: "multipart/form-data"

  defp serialize(query, variables, uploads) do
    uploads
    |> Map.put("query", query)
    |> Map.put("variables", json_encode!(variables))
  end

  defp json_encode!(variables) do
    Phoenix.json_library().json_encode!(variables)
  end

  defp build_response(%{"errors" => errors}) do
    {:error, Enum.map(errors, &build_error/1)}
  end

  defp build_response(%{"data" => data}) do
    {:ok, data}
  end

  defp build_error(%{"message" => message, "extensions" => extensions}) do
    {message, extensions}
  end

  defp build_error(%{"message" => message}) do
    message
  end
end
