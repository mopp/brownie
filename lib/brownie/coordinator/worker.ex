# TODO: Is is better to use Task ?
defmodule Brownie.Coordinator.Worker do
  if Mix.env() == :test do
    @compile :export_all
    @compile :nowarn_export_all
  end

  require Logger
  use GenServer, restart: :temporary

  # @typep key() :: Brownie.key()
  # @typep value() :: Brownie.value()
  @typep query() :: Brownie.Query.t()
  @typep result() :: :ok | {:ok, term()} | {:error, reason :: term()}

  def start_link([]) do
    GenServer.start_link(__MODULE__, [])
  end

  @spec request(pid(), query()) :: result()
  def request(pid, query) do
    GenServer.call(pid, {:request, query})
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl GenServer
  def handle_call({:request, query}, _, state) do
    # FIXME: There is possibility of sending a downed node while repairing
    # Flow:
    #   1. Down a node
    #   2. Receive request here.
    #   3. Use `Brownie.Application.get_cluster_members()` includes the downed node.
    #   4. Select the node as replica node.
    {:reply,
     handle_request(
       query,
       Brownie.Application.get_cluster_members(),
       Brownie.Application.get_replica_count()
     ), state}
  end

  # Handle the given request query.
  # This function does
  # - Calculate the hash of the key.
  # - Select the replica nodes.
  # - Try to exeucute the query at the replica nodes.
  @spec handle_request(query(), [node()], non_neg_integer()) :: result()
  defp handle_request(query, nodes, replica_count) do
    case nodes do
      [] ->
        # Standalone mode
        Logger.debug("Standalone mode")
        Brownie.Storage.request(query)

      nodes when length(nodes) < replica_count ->
        # Not supported failure case.
        {:error, {:not_enough_replica_nodes, nodes}}

      nodes ->
        case Brownie.Query.get_key(query) do
          {:ok, key} ->
            replica_nodes = Brownie.Coordinator.Util.find_replica_nodes(key, nodes, replica_count)
            Logger.debug("Execute: #{inspect(query)} -> #{inspect(replica_nodes)}")

            # TODO: execute asynchronously
            replica_nodes
            |> Enum.map(fn node -> :rpc.call(node, Brownie.Storage, :request, [query]) end)
            |> handle_replica_results(replica_nodes, replica_count)

          {:error, _} = error ->
            error
        end
    end
  end

  @spec handle_replica_results([result()], [node()], non_neg_integer()) :: result()
  defp handle_replica_results(results, replica_nodes, replica_count) do
    Logger.debug("Results: #{inspect(List.zip([replica_nodes, results]))}")

    {count_oks, result} =
      List.foldl(results, {0, nil}, fn
        :ok, {count, _} ->
          {count + 1, :ok}

        {:ok, _} = ok, {count, _} ->
          {count + 1, ok}

        _, acc ->
          acc
      end)

    if div(replica_count, 2) < count_oks do
      # TODO: Retry sending the request asynchronously to the error nodes.
      result
    else
      reasons =
        List.zip([replica_nodes, results])
        |> List.foldl(
          [],
          fn
            {node, {:error, reason}}, acc ->
              [{node, reason} | acc]

            _, acc ->
              acc
          end
        )
        |> Enum.reverse()

      {:error, reasons}
    end
  end
end
