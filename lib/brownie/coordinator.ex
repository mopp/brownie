defmodule Brownie.Coordinator do
  @moduledoc """
  Coordinator public APIs.
  """
  @typep query() :: Brownie.Query.t()

  @spec request(query()) :: :ok | {:ok, term()} | {:error, reason :: term()}
  def request(query) do
    case Brownie.Coordinator.Supervisor.start_child() do
      {:ok, pid} ->
        Brownie.Coordinator.Worker.request(pid, query)

      {:error, _} = error ->
        error
    end
  end
end
