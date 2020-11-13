defmodule Absinthe.ConnTest.Test.Schema do
  use Absinthe.Schema

  import_types(Absinthe.Plug.Types)

  object :file do
    field(:filename, :string)
  end

  object :profile do
    field(:name, :string)
    field(:image, :file)
  end

  input_object :profile_input do
    field(:name, non_null(:string))
    field(:image, :upload)
  end

  query do
    field :hello, :string do
      arg(:name, :string, default_value: "world")

      resolve(fn args, _ ->
        {:ok, "Hello, #{args.name}!"}
      end)
    end
  end

  mutation do
    field :create_profile, :profile do
      arg(:data, :profile_input)

      resolve(fn %{data: data}, _ ->
        if data.name == "" do
          {:error, "Name can't be blank"}
        else
          {:ok, data}
        end
      end)
    end
  end
end
