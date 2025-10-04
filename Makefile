.PHONY: up down

up: ## Sobe tudo em pipeline (env -> compose -> wait -> seed -> test)
	@echo "📦 Gerando variáveis de ambiente..."
	bash scripts/get-env.sh

	@echo "🚀 Subindo cluster com Docker Compose..."
	docker compose -f compose/docker-compose.yml up -d

	@echo "⏳ Aguardando cluster ficar disponível..."
	bash scripts/wait-for-http.sh http://localhost:9200

	@echo "🌱 Injetando index templates..."
	bash scripts/seed-index-templates.sh

	@echo "🧪 Rodando testes..."
	bash scripts/tests.sh

	@echo "✅ OK! Cluster pronto para uso."

down: ## Derruba tudo (containers, volumes e rede)
	@echo "🛑 Derrubando cluster e removendo volumes..."
	docker compose -f compose/docker-compose.yml down -v
