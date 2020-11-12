defmodule Absinthe.ConnTest.Loader do
  @moduledoc """
  Reads a file containing GraphQL queries and parses them.
  """

  @patterns [
    ~r/^(fragment|query|mutation|subscription) (?<query>\w+)/,
    ~r/^\s*\.{3}(?<fragment>\w+)$/
  ]

  def load(path) do
    path
    |> File.stream!()
    |> Enum.to_list()
    |> Enum.reduce({%{}, nil}, &reduce/2)
    |> stash_query()
  end

  defp reduce(line, acc) do
    case parse(line) do
      %{"query" => name} -> put_new_query(acc, name, line)
      %{"fragment" => name} -> put_fragment(acc, name, line)
      nil -> put_more_query(acc, line)
    end
  end

  defp stash_query({queries, nil}) do
    queries
  end

  defp stash_query({queries, {name, query}}) do
    Map.put(queries, name, query)
  end

  defp put_new_query(acc, name, line) do
    {stash_query(acc), {name, line}}
  end

  defp put_more_query({queries, {name, query}}, line) do
    {queries, {name, query <> line}}
  end

  defp put_fragment({queries, {name, query}}, fragment_name, line) do
    fragment = Map.fetch!(queries, fragment_name)
    {queries, {name, fragment <> query <> line}}
  end

  defp parse(line) do
    Enum.find_value(@patterns, &Regex.named_captures(&1, line))
  end
end
