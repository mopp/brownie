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
end
