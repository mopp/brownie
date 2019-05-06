defmodule Brownie.Application do
  @moduledoc """
  Main application module starts the all processes for Brownie.
  """

  use Application

  @impl Application
  def start(_type, _args) do
    # TODO: Wait making the cluster here.

    # List all child processes to be supervised.
    children = [
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
end
