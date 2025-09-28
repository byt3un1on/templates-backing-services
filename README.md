# OpenSearch Backing Service Template

Este projeto é um template completo para provisionar rapidamente um cluster OpenSearch (2 nós) e OpenSearch Dashboards em ambiente de desenvolvimento, usando Docker Compose. Ele automatiza a configuração de variáveis de ambiente, subida dos containers, aplicação de index templates e ingest pipelines, além de executar testes básicos de saúde do cluster.

---

## Sumário

- [Visão Geral](#visão-geral)
- [Pré-requisitos](#pré-requisitos)
- [Como Usar](#como-usar)
- [Comandos Principais](#comandos-principais)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Pipelines e Automatizações](#pipelines-e-automatizações)
- [Customização](#customização)
- [CI/CD](#cicd)
- [Observações](#observações)

---

## Visão Geral

- **Provisiona**: 2 nós OpenSearch + OpenSearch Dashboards via Docker Compose.
- **Ambiente**: Focado em desenvolvimento (segurança desabilitada).
- **Automação**: Gera `.env`, sobe containers, aplica index templates e ingest pipelines, executa testes de saúde.
- **Seed**: Aplica automaticamente templates e pipelines do diretório `bootstrap/` ao cluster.
- **Testes**: Verifica saúde do cluster, criação/deleção de índices e status do Dashboards.
- **CI/CD**: Workflows prontos para integração contínua.

---

## Pré-requisitos

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)
- [GNU Make](https://www.gnu.org/software/make/)
- Bash

---

## Como Usar

1. **Clone o repositório**
   ```sh
   git clone <url-do-repo>
   cd templates-backing-services
   ```

2. **Suba todo o ambiente, aplique seeds e rode testes**
   ```sh
   make up
   ```
   Isso irá:
   - Gerar o arquivo `.env` (via `scripts/get-env.sh`)
   - Subir os containers do cluster
   - Aplicar index templates e ingest pipelines
   - Rodar testes básicos de saúde

3. **Derrube o ambiente**
   ```sh
   make down
   ```

---

## Comandos Principais

- **make up**  
  Sobe todo o ambiente, aplica seeds e executa testes.

- **make down**  
  Derruba todos os containers e remove volumes.

- **make**  
  Você pode rodar os scripts individualmente, se desejar:
  - `bash scripts/get-env.sh` — Gera o arquivo `.env`
  - `docker compose -f compose/docker-compose.yml up -d` — Sobe os containers
  - `bash scripts/seed-index-templates.sh` — Aplica index templates e pipelines
  - `bash scripts/tests.sh` — Executa testes básicos

---

## Estrutura do Projeto

```
.
├── .env.example                # Exemplo de variáveis de ambiente
├── Makefile                    # Orquestração dos comandos principais
├── compose/
│   └── docker-compose.yml      # Compose para ambiente de desenvolvimento
├── scripts/
│   ├── get-env.sh              # Gera o arquivo .env
│   ├── seed-index-templates.sh # Aplica index templates e pipelines
│   ├── tests.sh                # Testes básicos de saúde do cluster
│   └── wait-for-http.sh        # Aguarda endpoint HTTP responder
├── bootstrap/
│   ├── index-templates/        # Index templates para seed
│   └── ingest-pipelines/       # Ingest pipelines para seed
├── .github/
│   └── workflows/              # Workflows de CI/CD
│       ├── 001_pr_to_dev.yaml
│       ├── 002_pr_to_hom.yaml
│       ├── 003_pr_to_prd.yaml
│       └── 004_tag_&_release.yaml
└── config/                     # (Reservado para configs customizadas)
```

---

## Pipelines e Automatizações

### Pipeline Local (`make up`)

1. **Gera variáveis de ambiente** (`scripts/get-env.sh`)
2. **Sobe containers** (`docker-compose.yml`)
3. **Aguarda cluster ficar disponível** (`scripts/wait-for-http.sh`)
4. **Aplica index templates e pipelines** (`scripts/seed-index-templates.sh`)
5. **Executa testes básicos** (`scripts/tests.sh`)

### Seed

- Todos os arquivos em `bootstrap/index-templates/` e `bootstrap/ingest-pipelines/` são aplicados automaticamente ao cluster ao subir o ambiente.

---

## Customização

- **Variáveis de ambiente**:  
  Edite `.env` para customizar nomes, versões, portas, recursos, etc.

- **Index templates e pipelines**:  
  Adicione ou edite arquivos em `bootstrap/index-templates/` e `bootstrap/ingest-pipelines/`.

- **Testes**:  
  Edite `scripts/tests.sh` para adicionar ou modificar verificações de saúde.

---

## CI/CD

- Workflows em `.github/workflows/` para integração contínua em diferentes ambientes (dev, homologação, produção, release).
- Os pipelines podem ser adaptados para rodar os mesmos scripts de seed e teste em ambientes de CI.

---

## Observações

- **Ambiente focado em desenvolvimento**: Segurança desabilitada por padrão.
- **Para produção**: Adapte o compose, scripts e variáveis para ativar TLS, autenticação e roles.
- **Persistência**: Dados dos nós OpenSearch são persistidos em volumes Docker.
- **Dashboards**: Interface web disponível na porta definida em `.env` (padrão: 5601).

---

## Dúvidas ou problemas?

Abra uma issue ou consulte os scripts e arquivos de configuração para entender o fluxo detalhado.

---