# ---- Compose config ---------------------------------------------------------
COMPOSE ?= docker-compose-outline.yml
ENV     ?= .env
APP_URL ?= http://localhost:3000

DC = docker compose -f $(COMPOSE) --env-file $(ENV)

# ---- Common targets ---------------------------------------------------------
.PHONY: up down ps logs restart health verify

up:        ## Start the stack
	$(DC) up -d

down:      ## Stop the stack
	$(DC) down

ps:        ## Show containers
	$(DC) ps

logs:      ## Tail logs (Ctrl+C to exit)
	$(DC) logs -f --tail=100

restart:   ## Restart only the app container
	$(DC) restart outline

health:    ## Probe the web app on :3000
	@echo "Probing Outline on :3000 ..."
	@code=$$(curl -s -o /dev/null -w "%{http_code}" $(APP_URL)); \
	if [ "$$code" -ge 200 ] && [ "$$code" -lt 400 ]; then \
	  echo "OK"; exit 0; \
	else \
	  echo "Got HTTP $$code"; exit 1; \
	fi

verify:    ## Run local verification (env parity, compose, HTTP)
	COMPOSE_FILE=$(COMPOSE) ENV_FILE=$(ENV) bash scripts/verify-dev.sh
