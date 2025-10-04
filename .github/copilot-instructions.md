# OpenSearch Backing Service Template - AI Coding Instructions

## Project Overview
This is an OpenSearch development template that automates cluster provisioning using a **pipeline-based architecture**. The core pattern is: `env generation → docker-compose → health checks → seeding → testing`.

## Key Architectural Patterns

### Bootstrap-First Design
- All index templates go in `bootstrap/index-templates/*.json` and are auto-applied via `scripts/seed-index-templates.sh`
- All ingest pipelines go in `bootstrap/ingest-pipelines/*.json` and use the same seeding mechanism
- **Critical**: Template names must match filenames (e.g., `logs-template.json` creates template named `logs-template`)
- Seeding uses OpenSearch REST API: `PUT /_index_template/{name}` and `PUT /_ingest/pipeline/{name}`

### Development-Only Security Model
- Security plugins are **disabled** (`DISABLE_SECURITY_PLUGIN=true`)
- No authentication required for API calls
- **Never** add security configs - this is a dev template only

### Environment Generation Pattern
```bash
# Always use this instead of manual .env creation
make up  # Calls scripts/get-env.sh which generates unique cluster names
```
- Cluster names are auto-generated with timestamps to avoid conflicts
- `.env` is never overwritten if it exists
- All Docker services use environment variable substitution with sensible defaults

### Testing Philosophy
The `scripts/tests.sh` follows a specific verification order:
1. Cluster health check (`_cluster/health`)
2. CRUD operations (create → insert → search → delete test index)
3. Bootstrap verification (confirms all templates and pipelines exist)
4. Dashboards health check

## Development Workflow Commands

```bash
# Complete pipeline (most common)
make up     # Full bootstrap: env → compose → wait → seed → test

# Teardown
make down   # Removes containers AND volumes (-v flag)

# Manual pipeline steps (rarely needed)
bash scripts/get-env.sh              # Generate .env
docker compose -f compose/docker-compose.yml up -d
bash scripts/wait-for-http.sh http://localhost:9200
bash scripts/seed-index-templates.sh
bash scripts/tests.sh
```

## File Modification Patterns

### Adding Index Templates
1. Create `bootstrap/index-templates/{name}.json` with OpenSearch index template format
2. Template automatically applies on next `make up`
3. Add verification in `scripts/tests.sh` template check loop

### Adding Ingest Pipelines  
1. Create `bootstrap/ingest-pipelines/{name}.json` with OpenSearch pipeline format
2. Pipeline automatically applies on next `make up`  
3. Add verification in `scripts/tests.sh` pipeline check loop

### Environment Variables
- Modify `.env.example` for new defaults
- Use `${VAR:-default}` syntax in `docker-compose.yml`
- **Never** hardcode ports or resource limits

### Docker Compose Structure
- 2-node OpenSearch cluster with cross-node discovery
- Dashboards points to both nodes for HA
- All services use `opensearch-net` network
- Data persistence via named volumes (`opensearch-data1`, `opensearch-data2`)

## CI/CD Integration Points

Workflows in `.github/workflows/` use shared actions from `byt3un1on/shared-github-actions`. The same scripts (`seed-index-templates.sh`, `tests.sh`) work in CI environments.

## Common Debugging Commands

```bash
# Check cluster status
curl http://localhost:9200/_cluster/health

# List applied templates  
curl http://localhost:9200/_index_template

# List applied pipelines
curl http://localhost:9200/_ingest/pipeline

# Check Dashboards
curl http://localhost:5601/api/status
```

## Portuguese Comments Convention
This codebase uses Portuguese comments and output messages. Maintain this convention when adding new scripts or modifying existing ones.