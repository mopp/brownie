defmodule Brownie.Coordinator.Stabilizer do
  require Logger
  use GenServer

  @doc false
  def start_link(nodes) do
    GenServer.start_link(__MODULE__, nodes)
  end

  @impl GenServer
  def init(nodes) do
    if Enum.all?(Enum.map(nodes, &(Node.monitor(&1, true)))) do
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
      stabilize(node)
      {:noreply, nodes}
    else
      Logger.error("Got unknown nodedown #{inspect(node)}")
      {:noreply, nodes}
    end
  end

  defp stabilize(node) do
    :ok
  end
end
