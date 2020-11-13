defmodule Absinthe.ConnTest.Loader.Query do
  defstruct [:name, :type, :needs, :source]

  @type type :: :fragment | :query | :mutation | :subscription

  @type t :: %__MODULE__{
          name: String.t(),
          type: type(),
          needs: [binary()],
          source: String.t()
        }
end
