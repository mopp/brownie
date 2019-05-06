defmodule Brownie.Coordinator.Stabilizer do
  require Logger
  use GenServer

  @typep key() :: Brownie.key()

  @doc false
  def start_link(nodes) do
    GenServer.start_link(__MODULE__, nodes)
  end

  @impl GenServer
  def init(nodes) do
    if Enum.all?(Enum.map(nodes, &Node.monitor(&1, true))) do
      Logger.info("Monitor nodes: #{inspect(nodes)}")
      {:ok, nodes}
    else
      {:stop, :node_monitor_failed}
    end
  end

  @impl GenServer
  def handle_info({:nodedown, node}, nodes) do
    if Enum.member?(nodes, node) do
      Logger.error("Detect nodedown #{inspect(node)}")

      result =
        case Brownie.Storage.keys() do
          {:ok, keys} ->
            stabilize(node, keys)

          {:error, reason} ->
            {:error, {:cannot_retrive_keys, reason}}
        end

      Logger.info("Stabilization result: #{inspect(result)}")
      {:noreply, nodes}
    else
      Logger.error("Got unknown nodedown #{inspect(node)}")
      {:noreply, nodes}
    end
  end

  @spec stabilize(node(), [key()]) :: :ok | {:error, reason :: term()}
  defp stabilize(down_node, keys) do
    old_replica_nodes = Brownie.Application.get_cluster_members()
    new_replica_nodes = old_replica_nodes -- [down_node]
    Brownie.Application.set_cluster_members(new_replica_nodes)

    replica_count = Brownie.Application.get_replica_count()

    target_keys = find_target_keys(keys, old_replica_nodes, replica_count)
    Logger.debug("Stabilize target keys: #{inspect(target_keys)}")

    results = Enum.map(target_keys, &replicate_again(&1, new_replica_nodes, replica_count))

    error_reasons =
      List.zip([target_keys, results])
      |> List.foldl(
        [],
        fn
          {_, :ok}, acc ->
            acc

          {key, {:error, reason}}, acc ->
            [{key, reason} | acc]
        end
      )

    if error_reasons == [] do
      :ok
    else
      {:error, error_reasons}
    end
  end

  # Find the keys need to be repaired.
  # it is target if the current node is 0th at the old replication nodes.
  @spec find_target_keys([key()], [node()], non_neg_integer()) :: [key()]
  defp find_target_keys(keys, old_replica_nodes, replica_count) do
    current_node = Node.self()

    Enum.filter(
      keys,
      fn key ->
        Brownie.Coordinator.Util.find_replica_nodes(key, old_replica_nodes, replica_count)
        |> Enum.find_index(&(&1 == current_node)) == 0
      end
    )
  end

  @spec replicate_again([key()], [node()], non_neg_integer()) :: :ok | {:error, reason :: term()}
  defp replicate_again(key, new_replica_nodes, replica_count) do
    case Brownie.Storage.read(key) do
      {:ok, value} ->
        replica_nodes =
          Brownie.Coordinator.Util.find_replica_nodes(key, new_replica_nodes, replica_count) --
            Node.list(:this)

        Logger.debug("Replicate again key: #{inspect(key)}, nodes: #{inspect(replica_nodes)}")

        error_reasons =
          List.foldl(
            replica_nodes,
            [],
            fn node, acc ->
              case :rpc.call(node, Brownie.Storage, :create, [key, value]) do
                :ok ->
                  acc

                {:error, :already_exist} ->
                  # Ignore this case.
                  acc

                {:error, reason} ->
                  [{node, reason} | acc]
              end
            end
          )

        if error_reasons == [] do
          if length(replica_nodes) == replica_count do
            Brownie.Storage.delete(key)
          end

          :ok
        else
          {:error, error_reasons}
        end

      {:error, _} = error ->
        error
    end
  end
end
