defmodule Brownie.Coordinator.WorkerTest do
  use ExUnit.Case, async: true

  test "select_nodes/3" do
    assert [:node1, :node2, :node3] ==
             Brownie.Coordinator.Worker.select_nodes(
               [:node1, :node2, :node3, :node4, :node5],
               0,
               3
             )

    assert [:node5, :node1, :node2] ==
             Brownie.Coordinator.Worker.select_nodes(
               [:node1, :node2, :node3, :node4, :node5],
               4,
               3
             )
  end

  test "handle_replica_results/3" do
    replica_nodes = [:node2, :node3, :node4]
    replica_count = 3

    assert :ok ==
             Brownie.Coordinator.Worker.handle_replica_results(
               [:ok, :ok, :ok],
               replica_nodes,
               replica_count
             )

    assert {:ok, "hoo"} ==
             Brownie.Coordinator.Worker.handle_replica_results(
               [{:ok, "hoo"}, {:ok, "hoo"}, {:error, :exunit}],
               replica_nodes,
               replica_count
             )

    assert {:error, [{:node3, :one}, {:node4, :two}]} ==
             Brownie.Coordinator.Worker.handle_replica_results(
               [:ok, {:error, :one}, {:error, :two}],
               replica_nodes,
               replica_count
             )
  end
end
