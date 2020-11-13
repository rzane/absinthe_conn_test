defmodule Absinthe.ConnTest.HTTP do
  def request(query, variables) when is_list(variables) do
    request(query, Map.new(variables))
  end

  def request(query, variables) when is_map(variables) do
    {variables, uploads, count} = extract_uploads(variables, %{}, 0)
    {serialize(query, variables, uploads), get_content_type(count)}
  end

  def response(%{"errors" => errors}) do
    {:error, Enum.map(errors, &normalize_error/1)}
  end

  def response(%{"data" => data}) do
    {:ok, data}
  end

  defp get_content_type(0), do: "application/json"
  defp get_content_type(_), do: "multipart/form-data"

  defp serialize(query, variables, uploads) do
    uploads
    |> Map.put("query", query)
    |> Map.put("variables", json_encode!(variables))
  end

  defp json_encode!(variables) do
    Phoenix.json_library().encode!(variables)
  end

  defp normalize_error(%{"message" => message, "extensions" => extensions}) do
    {message, extensions}
  end

  defp normalize_error(%{"message" => message}) do
    message
  end

  defp extract_uploads(%Plug.Upload{} = current, uploads, n) do
    key = "uploads/#{n}"
    uploads = Map.put(uploads, key, current)
    {key, uploads, n + 1}
  end

  defp extract_uploads(current, uploads, n) when is_map(current) do
    Enum.reduce(current, {%{}, uploads, n}, fn {key, value}, {next, uploads, n} ->
      {value, uploads, n} = extract_uploads(value, uploads, n)
      {Map.put(next, key, value), uploads, n}
    end)
  end

  defp extract_uploads(current, uploads, n) when is_list(current) do
    Enum.reduce(current, {[], uploads, n}, fn value, {next, uploads, n} ->
      {value, uploads, n} = extract_uploads(value, uploads, n)
      {next ++ [value], uploads, n}
    end)
  end

  defp extract_uploads(current, uploads, n) do
    {current, uploads, n}
  end
end
