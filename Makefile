.PHONY: run
run: build
	docker-compose up

.PHONY: build
build:
	mix deps.get
	mix compile
	docker-compose build

.PHONY: attach
attach:
	docker-compose exec one iex --cookie develop --hidden --name mopp@brownie1.com --remsh one@brownie1.com

.PHONY: down
down:
	docker-compose down
