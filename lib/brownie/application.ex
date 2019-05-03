defmodule Brownie.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    # TODO: Load configurations here.
    storage_backend = Brownie.StorageMemory

    set_backend(storage_backend)

    # List all child processes to be supervised
    children = [
      storage_backend
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def get_backend() do
    Application.get_env(__MODULE__, :backend, Brownie.StorageMemory)
  end

  defp set_backend(backend) do
    Application.put_env(__MODULE__, :backend, backend)
  end
end
