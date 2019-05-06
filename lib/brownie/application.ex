defmodule Brownie.Application do
  @moduledoc """
  Main application module starts the all processes for Brownie.
  """

  require Logger
  use Application

  @impl Application
  def start(_type, _args) do
    Logger.info("Start Brownie")

    members = get_cluster_members()

    children =
      if length(members) == 0 do
        # Standalone mode.
        []
      else
        # Try to make the cluster.
        members = get_cluster_members() -- Node.list(:this)
        connect_cluster_members!(members)
        [{Brownie.Coordinator.Stabilizer, members}]
      end

    children =
      children ++
        [
          Brownie.Coordinator.Supervisor,
          get_backend()
        ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def get_backend() do
    Application.get_env(:brownie, :storage_backend, Brownie.StorageMemory)
  end

  def get_cluster_members() do
    Application.fetch_env!(:brownie, :cluster_members)
  end

  def get_replica_count() do
    Application.get_env(:brownie, :replica_count, 3)
  end

  defp connect_cluster_members!(members) do
    pid = self()

    for member <- members do
      Process.spawn(
        fn ->
          send(pid, connect_with_retry(member, 10, 100))
        end,
        []
      )
    end

    for _ <- members do
      receive do
        {:ok, node} ->
          Logger.info("Connect to #{inspect(node)}")

        {:error, node} ->
          msg = "Cannot connect to #{inspect(node)}"
          Logger.error(msg)
          raise(msg)
      end
    end
  end

  @spec connect_with_retry(node(), 0, non_neg_integer()) :: {:error, {:timeout, node()}}
  defp connect_with_retry(node, 0, _) do
    {:error, {:timeout, node}}
  end

  @spec connect_with_retry(node(), non_neg_integer(), non_neg_integer()) ::
          {:ok, node()} | {:error, {:timeout, node()}}
  defp connect_with_retry(node, count, sleep_interval) do
    if true == Node.connect(node) do
      {:ok, node}
    else
      Process.sleep(sleep_interval)
      connect_with_retry(node, count - 1, sleep_interval)
    end
  end
end
