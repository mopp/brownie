defmodule Brownie.StorageTest do
  use ExUnit.Case, async: true

  test "create and read key-value" do
    assert :ok == Brownie.Storage.create(:key, "value")
    assert {:ok, "value"} == Brownie.Storage.read(:key)
  end
end
