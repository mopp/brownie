defmodule Brownie.StorageMemory do
  use GenServer

  alias Brownie.Storage
  @behaviour Storage

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl Storage
  def create(key, value) do
    GenServer.call(__MODULE__, {:create, key, value})
  end

  @impl Storage
  def read(key) do
    GenServer.call(__MODULE__, {:read, key})
  end

  @impl Storage
  def update(key, value) do
    GenServer.call(__MODULE__, {:update, key, value})
  end

  @impl Storage
  def delete(key) do
    GenServer.call(__MODULE__, {:delete, key})
  end

  @impl GenServer
  def init([]) do
    {:ok, %{}}
  end

  @impl GenServer
  def handle_call({:create, key, value}, _, map) do
    case map do
      %{^key => _} ->
        {:reply, {:error, :already_exist}, map}

      _ ->
        {:reply, :ok, Map.put(map, key, value)}
    end
  end

  @impl GenServer
  def handle_call({:read, key}, _, map) do
    case map do
      %{^key => value} ->
        {:reply, {:ok, value}, map}

      _ ->
        {:reply, {:error, :not_found}, map}
    end
  end

  @impl GenServer
  def handle_call({:update, key, value}, _, map) do
    case map do
      %{^key => _} ->
        {:reply, {:ok, value}, %{map | key => value}}

      _ ->
        {:reply, {:error, :not_found}, map}
    end
  end

  @impl GenServer
  def handle_call({:delete, key}, _, map) do
    case map do
      %{^key => _} ->
        {:reply, :ok, Map.delete(map, key)}

      _ ->
        {:reply, {:error, :not_found}, map}
    end
  end

  @impl GenServer
  def handle_cast(request, state) do
    {:stop, {:error, {:unknown_request, request}}, state}
  end
end
