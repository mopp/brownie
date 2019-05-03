defmodule Brownie.Storage do
  @typep reason() :: term()
  @typep key() :: Brownie.key()
  @typep value() :: Brownie.value()

  @callback create(key(), value()) :: :ok | {:error, reason()}
  @callback read(key()) :: {:ok, value()} | {:error, reason()}
  @callback update(key(), value()) :: :ok | {:error, reason()}
  @callback delete(key()) :: :ok | {:error, reason()}

  def create(key, value) do
    Brownie.Application.get_backend().create(key, value)
  end

  def read(key) do
    Brownie.Application.get_backend().read(key)
  end

  def update(key, value) do
    Brownie.Application.get_backend().update(key, value)
  end

  def delete(key) do
    Brownie.Application.get_backend().delete(key)
  end
end
