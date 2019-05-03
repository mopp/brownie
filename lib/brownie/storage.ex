defmodule Brownie.Storage do
  @typep reason() :: term()
  @typep key() :: Brownie.key()
  @typep value() :: Brownie.value()

  @callback create(key(), value()) :: :ok | {:error, reason()}
  @callback read(key()) :: {:ok, value()} | {:error, reason()}
  @callback update(key(), value()) :: :ok | {:error, reason()}
  @callback delete(key()) :: :ok | {:error, reason()}
end
