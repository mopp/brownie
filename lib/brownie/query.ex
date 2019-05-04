defmodule Brownie.Query do
  @typep key() :: Brownie.key()
  @typep value() :: Brownie.value()
  @type t() ::
          {:create, key, value}
          | {:read, key}
          | {:update, key, value}
          | {:delete, key}

  @spec get_key(t()) :: {:ok, key()} | {:error, {:got_unknown_query, term()}}
  def get_key(query) do
    case query do
      {_, key, _} ->
        {:ok, key}

      {_, key} ->
        {:ok, key}

      _ ->
        {:error, {:got_unknown_query, query}}
    end
  end
end
