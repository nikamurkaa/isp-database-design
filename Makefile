-include .env
export

POSTGRES_USER ?= portfolio
POSTGRES_DB ?= internet_provider

.PHONY: up down reset logs psql demo pgadmin

up:
	docker compose up -d postgres

down:
	docker compose down

reset:
	docker compose down -v
	docker compose up -d postgres

logs:
	docker compose logs -f postgres

psql:
	docker compose exec postgres psql -U $(POSTGRES_USER) -d $(POSTGRES_DB)

demo:
	docker compose exec postgres psql -U $(POSTGRES_USER) -d $(POSTGRES_DB) -f /docker-entrypoint-initdb.d/08_demo_queries.sql

pgadmin:
	docker compose --profile tools up -d
