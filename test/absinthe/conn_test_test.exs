defmodule Absinthe.ConnTestTest do
  use ExUnit.Case
  doctest Absinthe.ConnTest

  test "greets the world" do
    assert Absinthe.ConnTest.hello() == :world
  end
end
