defmodule Brownie.Application do
  @moduledoc """
  Main application module starts the all processes for Brownie.
  """

  use Application

  @impl Application
  def start(_type, _args) do
    # List all child processes to be supervised.
    children = [
      get_backend()
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  # TODO: refactor how to manage the configuration.
  def get_backend() do
    Application.get_env(:brownie, :storage_backend, Brownie.StorageMemory)
  end
end
