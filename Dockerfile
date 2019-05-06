FROM elixir:1.8

RUN mix local.hex --force

WORKDIR /app
