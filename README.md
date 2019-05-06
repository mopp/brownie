# Brownie

Hobby Distributed Key-Value Store

# Requirements

- elixir
- docker-compose

# How to test

```console
make run
```

On another console:

```console
make attach

iex(one@brownie1.com)> Brownie.Coordinator.request({:create, "abc", "def"})
:ok

iex(one@brownie1.com)> Brownie.Coordinator.request({:read, "abc"})
{:ok, "def"}

iex(one@brownie1.com)> Brownie.Coordinator.request({:update, "abc", "xyz"})
{:ok, "xyz"}

iex(one@brownie1.com)> Brownie.Coordinator.request({:delete, "abc"})
:ok

iex(one@brownie1.com)> Brownie.test false
```
