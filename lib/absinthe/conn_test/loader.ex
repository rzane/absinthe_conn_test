defmodule Absinthe.ConnTest.Loader do
  @moduledoc false

  alias Absinthe.Phase.Parse
  alias Absinthe.Language
  alias Absinthe.Language.Source
  alias Absinthe.Language.OperationDefinition
  alias Absinthe.Language.Fragment
  alias Absinthe.Language.FragmentSpread
  alias Absinthe.ConnTest.Error
  alias Absinthe.ConnTest.Loader.Query

  @typep input :: String.t()
  @typep lines :: [String.t()]

  defmodule Error do
    defexception [:message]
  end

  defmodule Query do
    @moduledoc false

    defstruct [:name, :needs, :source, :type]

    @type name :: String.t()
    @type needs :: [name()]
    @type source :: String.t()
    @type type :: :fixture | :query | :mutation | :subscription
    @type mapping :: %{name() => t()}
    @type t :: %__MODULE__{
            name: name(),
            type: type(),
            needs: needs(),
            source: source()
          }
  end

  @doc "Load all queries and fragments from a file"
  @spec load!(Path.t()) :: [Query.t()]
  def load!(path) do
    path
    |> File.read!()
    |> parse!(path)
  end

  @doc "Resolve all dependencies from queries"
  @spec resolve([Query.t()]) :: [Query.t()]
  def resolve(queries) do
    {fragments, operations} = Enum.split_with(queries, &(&1.type == :fragment))
    fragments = Map.new(fragments, &{&1.name, &1})
    Enum.map(operations, &resolve(&1, fragments))
  end

  defp resolve(%Query{needs: []} = query, _fragments) do
    query
  end

  defp resolve(%Query{source: source, needs: [need | needs]} = query, fragments) do
    fragment = fetch_fragment!(fragments, need)
    source = fragment.source <> source
    needs = needs ++ fragment.needs
    query = %Query{query | source: source, needs: needs}
    resolve(query, fragments)
  end

  @spec parse!(input(), Path.t()) :: [Query.t()]
  @dialyzer {:no_match, parse!: 2}
  defp parse!(input, path) do
    case Parse.run(%Source{name: path, body: input}) do
      {:ok, %{input: %{definitions: nodes}}} ->
        build(nodes, String.split(input, ~r/\r?\n/))

      {:error, blueprint} ->
        %{execution: %{validation_errors: [error]}} = blueprint
        %{message: message, locations: [%{line: line}]} = error
        raise Error, "#{message} (#{path}:#{line})"
    end
  end

  @spec build([Language.t()], lines()) :: [Query.t()]
  defp build(nodes, lines, queries \\ [])
  defp build([], _lines, queries), do: queries

  defp build([node | nodes], lines, queries) do
    query = %Query{
      name: node.name,
      type: get_type(node),
      needs: find_needs(node),
      source: get_source(node, nodes, lines)
    }

    build(nodes, lines, queries ++ [query])
  end

  @spec get_source(Language.t(), [Language.t()], lines()) :: Query.source()
  def get_source(a, [], lines) do
    start = {a.loc.line - 1, a.loc.column - 1}
    do_get_source(lines, start, {-1, -1})
  end

  def get_source(a, [b | _], lines) do
    start = {a.loc.line - 1, a.loc.column - 1}
    finish = {b.loc.line - 1, b.loc.column - 1}
    do_get_source(lines, start, deduct(finish))
  end

  defp deduct({line, 0}), do: {line - 1, -1}
  defp deduct({line, column}), do: {line, column - 1}

  defp do_get_source(lines, {a, b}, {c, d}) do
    lines |> Enum.slice(a..c) |> Enum.join("\n") |> String.slice(b..d)
  end

  @spec get_type(Language.t()) :: Query.type()
  defp get_type(%OperationDefinition{operation: type}), do: type
  defp get_type(%Fragment{}), do: :fragment

  @spec find_needs(Language.t()) :: Query.needs()
  defp find_needs(node, names \\ [])

  defp find_needs(%FragmentSpread{name: name}, names) do
    [name | names]
  end

  defp find_needs(%{selection_set: %{selections: fields}}, names) do
    Enum.flat_map(fields, &find_needs(&1, names))
  end

  defp find_needs(_, names) do
    names
  end

  @spec fetch_fragment!(Query.mapping(), Query.name()) :: Query.t()
  defp fetch_fragment!(fragments, name) do
    case Map.fetch(fragments, name) do
      {:ok, fragment} ->
        fragment

      :error ->
        names = fragments |> Map.keys() |> inspect()

        raise Error, """
        Fragment '#{name}' does not exist. Valid fragments are: #{names}
        """
    end
  end
end
