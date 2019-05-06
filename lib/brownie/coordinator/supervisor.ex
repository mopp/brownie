defmodule Brownie.Coordinator.Supervisor do
  @moduledoc """
  Coordinator supervisor module.
  `Brownie.Coordinator.Worker` responses to a request actually.
  """

  use DynamicSupervisor

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def start_child() do
    spec = {Brownie.Coordinator.Worker, []}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  @impl DynamicSupervisor
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
