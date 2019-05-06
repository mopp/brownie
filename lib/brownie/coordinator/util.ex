defmodule Brownie.Coordinator.Util do
  @spec find_replica_nodes(term(), [node()], non_neg_integer()) :: [node()]
  def find_replica_nodes(term, nodes, replica_count) do
    base_index = rem(term_to_hash(term), length(nodes))
    select_nodes(nodes, base_index, replica_count)
  end

  @spec term_to_hash(term()) :: non_neg_integer()
  def term_to_hash(term) do
    # FIXME: use better hash method.
    :crypto.bytes_to_integer(:erlang.term_to_binary(term))
  end

  @spec select_nodes([node()], non_neg_integer(), non_neg_integer()) :: [node()]
  def select_nodes(nodes, base_index, replica_count) do
    Enum.slice(Enum.concat(nodes, nodes), base_index..(base_index + replica_count - 1))
  end
end
