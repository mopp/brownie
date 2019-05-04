defmodule Brownie.Storage do
  @moduledoc """
  Define CRUD interfaces for storage backends.
  Provide common functions in order to use the CRUD functions.
  """

  @typep reason() :: term()
  @typep key() :: Brownie.key()
  @typep value() :: Brownie.value()

  @callback create(key(), value()) :: :ok | {:error, reason()}
  @callback read(key()) :: {:ok, value()} | {:error, reason()}
  @callback update(key(), value()) :: :ok | {:error, reason()}
  @callback delete(key()) :: :ok | {:error, reason()}

  @doc """
  Execute the given query.
  """
  @spec request(Brownie.Query.t()) :: :ok | {:ok, value()} | {:error, reason()}
  def request(query) do
    case query do
      {:create, key, value} ->
        create(key, value)

      {:read, key} ->
        read(key)

      {:update, key, value} ->
        update(key, value)

      {:delete, key} ->
        delete(key)

      _ ->
        {:error, {:got_unknown_query, query}}
    end
  end

  @doc """
  Create Key-Value pair.
  """
  @spec create(key(), value()) :: :ok | {:error, reason()}
  def create(key, value) do
    Brownie.Application.get_backend().create(key, value)
  end

  @doc """
  Read the value refereed by the given key.
  """
  @spec read(key()) :: {:ok, value()} | {:error, reason()}
  def read(key) do
    Brownie.Application.get_backend().read(key)
  end

  @doc """
  Update the value refereed by the given key.
  Return `{:error, _}` if no key.
  """
  @spec update(key(), value()) :: :ok | {:error, reason()}
  def update(key, value) do
    Brownie.Application.get_backend().update(key, value)
  end

  @doc """
  Delete the value refereed by the given key.
  """
  @spec delete(key()) :: :ok | {:error, reason()}
  def delete(key) do
    Brownie.Application.get_backend().delete(key)
  end
end
