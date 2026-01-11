SHELL := /bin/bash
DC_FILE := .devcontainer/docker-compose.yml
SERVICE := dev

.PHONY: help up down shell logs ps claude claude-login version test build clean new

help:
	@echo "Targets:"
	@echo "  make up           - Start the devcontainer service (detached)"
	@echo "  make shell        - Open a bash shell inside the container"
	@echo "  make claude       - Run Claude Code (interactive) inside the container"
	@echo "  make claude-login - Run 'claude login' inside the container"
	@echo "  make version      - Print versions (claude/node/rust/cargo)"
	@echo "  make build        - Run 'cargo build' in /workspaces/repo"
	@echo "  make test         - Run 'cargo test' in /workspaces/repo"
	@echo "  make logs         - Tail container logs"
	@echo "  make ps           - Show compose services"
	@echo "  make down         - Stop + remove containers AND volumes"
	@echo "  make clean        - Same as down (alias)"

up:
	docker compose -f $(DC_FILE) up -d --build

shell:
	docker compose -f $(DC_FILE) exec -it $(SERVICE) bash

claude:
	docker compose -f $(DC_FILE) exec -it $(SERVICE) bash -lc "claude"

claude-login:
	docker compose -f $(DC_FILE) exec -it $(SERVICE) bash -lc "claude login"

version:
	docker compose -f $(DC_FILE) exec -it $(SERVICE) bash -lc "\
		set -e; \
		echo 'claude:'; claude --version; \
		echo; echo 'node:'; node -v; \
		echo; echo 'npm:'; npm -v; \
		echo; echo 'rustc:'; rustc -V; \
		echo; echo 'cargo:'; cargo -V; \
	"

build:
	docker compose -f $(DC_FILE) exec -it $(SERVICE) bash -lc "cd /workspaces/repo && cargo build"

test:
	docker compose -f $(DC_FILE) exec -it $(SERVICE) bash -lc "cd /workspaces/repo && cargo test"

logs:
	docker compose -f $(DC_FILE) logs -f --tail=200

ps:
	docker compose -f $(DC_FILE) ps

down:
	docker compose -f $(DC_FILE) down -v --remove-orphans

clean: down

new:
	@./scripts/new-sandbox.sh $(REPO) $(DIR)
