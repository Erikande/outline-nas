COMPOSE ?= docker-compose-outline.yml
ENV ?= .env
ps:        ; docker compose -f $(COMPOSE) --env-file $(ENV) ps
up:        ; docker compose -f $(COMPOSE) --env-file $(ENV) up -d
down:      ; docker compose -f $(COMPOSE) --env-file $(ENV) down
logs:      ; docker compose -f $(COMPOSE) --env-file $(ENV) logs -f --tail=100
restart:   ; $(MAKE) down && $(MAKE) up
health:
	@echo "Probing Outline on :3000 ..."
	@curl -sS http://localhost:3000 >/dev/null && echo "OK" || (echo "NOT READY" && exit 1)

verify:
	@echo "Running Jules tests..."
	@bash scripts/jules-run-tests.sh
