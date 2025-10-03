# ==== Config ====
COMPOSE ?= docker-compose-outline.yml
ENV ?= .env
APP_URL ?= http://localhost:3000

.PHONY: up down ps logs restart health verify

up: ## Start stack
	docker compose -f $(COMPOSE) --env-file $(ENV) up -d

down: ## Stop stack
	docker compose -f $(COMPOSE) --env-file $(ENV) down

ps: ## Show services
	docker compose -f $(COMPOSE) --env-file $(ENV) ps

logs: ## Tail logs
	docker compose -f $(COMPOSE) --env-file $(ENV) logs -f --tail=100

restart: ## Restart web app only
	docker compose -f $(COMPOSE) --env-file $(ENV) restart outline

health: ## Probe http://localhost:3000
	@echo "Probing Outline on :3000 ..."
	@code=$$(curl -s -o /dev/null -w "%{http_code}" $(APP_URL)); \
	 if echo $$code | grep -Eq '^(2|3)'; then echo OK; else echo "HTTP $$code"; exit 1; fi

verify: ## Run local verification (env parity, compose config, HTTP)
	COMPOSE_FILE=$(COMPOSE) ENV_FILE=$(ENV) APP_URL=$(APP_URL) bash scripts/verify-dev.sh

# noop sanity 18:59:39
