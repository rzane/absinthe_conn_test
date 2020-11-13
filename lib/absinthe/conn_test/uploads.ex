defmodule Absinthe.ConnTest.Uploads do
  @moduledoc """
  Extract uploads from the query variables.

  See https://hexdocs.pm/absinthe/file-uploads.html#content
  """

  def extract(variables) do
    extract(variables, %{}, 0)
  end

  defp extract(%Plug.Upload{} = current, uploads, n) do
    key = "uploads/#{n}"
    uploads = Map.put(uploads, key, current)
    {key, uploads, n + 1}
  end

  defp extract(current, uploads, n) when is_map(current) do
    Enum.reduce(current, {%{}, uploads, n}, fn {key, value}, {next, uploads, n} ->
      {value, uploads, n} = extract(value, uploads, n)
      {Map.put(next, key, value), uploads, n}
    end)
  end

  defp extract(current, uploads, n) when is_list(current) do
    Enum.reduce(current, {[], uploads, n}, fn value, {next, uploads, n} ->
      {value, uploads, n} = extract(value, uploads, n)
      {next ++ [value], uploads, n}
    end)
  end

  defp extract(current, uploads, n) do
    {current, uploads, n}
  end
end
