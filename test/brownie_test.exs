defmodule BrownieTest do
  use ExUnit.Case
  doctest Brownie

  test "greets the world" do
    assert Brownie.hello() == :world
  end
end
