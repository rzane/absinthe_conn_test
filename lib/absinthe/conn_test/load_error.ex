defmodule Absinthe.ConnTest.LoadError do
  @moduledoc "Raised when a query can't be parsed"
  defexception [:message]
end
