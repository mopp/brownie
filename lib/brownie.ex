defmodule Brownie do
  @moduledoc """
  Brownie: Hobby Distributed Key-Value Store

  This module provides public APIs.
  """

  @type key() :: term()
  @type value() :: term()

  @doc """
  Hello world.

  ## Examples

      iex> Brownie.hello()
      :world

  """
  def hello do
    :world
  end

  def test(is_wait \\ true) do
    kvs = [
      {"hoge", "fuga"},
      {"piyo", "poyo"},
      {"foo", "bar"},
      {"erlang", "ok"},
      {"elixir", ":ok"}
    ]

    members = Brownie.Application.get_cluster_members()

    # Create test values.
    results =
      kvs
      |> Enum.map(fn {key, value} -> {:create, key, value} end)
      |> do_async(members)

    if not Enum.all?(results, &(:ok == &1)) do
      raise("Create values failed! Results: #{inspect(results)}")
    end

    # Down a node.
    Enum.at(Brownie.Application.get_cluster_members(), 1)
    |> :rpc.call(:erlang, :halt, [])

    if is_wait do
      # Wait for stabilization (cheating).
      Process.sleep(3 * 1000)
    end

    members = Brownie.Application.get_cluster_members()

    # Read them again.
    results =
      kvs
      |> Enum.map(fn {key, _} -> {:read, key} end)
      |> do_async(members)
      |> Enum.sort()

    expecteds =
      kvs
      |> Enum.map(fn {_, v} -> {:ok, v} end)
      |> Enum.sort()

    if not (results == expecteds) do
      raise("Read values failed after node down! Results: #{inspect(results)}")
    end

    :ok
  end

  defp do_async(queries, members) do
    tasks =
      for query <- queries do
        Task.async(:rpc, :call, [
          Enum.random(members),
          Brownie.Coordinator,
          :request,
          [query]
        ])
      end

    for task <- tasks do
      Task.await(task)
    end
  end
end
