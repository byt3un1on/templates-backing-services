#!/usr/bin/env bash
set -euo pipefail

OPENSEARCH_URL="${OPENSEARCH_URL:-http://localhost:9200}"
DASHBOARDS_URL="${DASHBOARDS_URL:-http://localhost:5601}"
OPENSEARCH_USER="${OPENSEARCH_USER:-}"
OPENSEARCH_PASS="${OPENSEARCH_PASS:-}"

auth_args=()
if [[ -n "$OPENSEARCH_USER" ]]; then
  auth_args=(-u "$OPENSEARCH_USER:$OPENSEARCH_PASS")
fi

hr() { echo "--------------------------------------------------------------------------------"; }

# 1. Teste de saúde do cluster
echo "🔎 Testando cluster OpenSearch em $OPENSEARCH_URL ..."
health=$(curl -fsSL "${auth_args[@]}" "$OPENSEARCH_URL/_cluster/health")
echo "$health"
status=$(echo "$health" | grep -o '"status":"[^"]*"' | cut -d: -f2 | tr -d '"')
if [[ "$status" != "green" && "$status" != "yellow" ]]; then
  echo "❌ Cluster não saudável (status: $status)"
  exit 1
fi
echo "✅ OpenSearch cluster saudável!"
hr

# 2. Teste de CRUD básico
echo "🔎 Criando índice de teste ..."
curl -fsSL "${auth_args[@]}" -XPUT "$OPENSEARCH_URL/test-index" \
  -H 'Content-Type: application/json' -d '{"settings":{"number_of_shards":1,"number_of_replicas":0}}'

echo "🔎 Injetando documento de teste ..."
curl -fsSL "${auth_args[@]}" -XPOST "$OPENSEARCH_URL/test-index/_doc?refresh=true" \
  -H 'Content-Type: application/json' -d '{"message":"Teste de inserção no OpenSearch"}'

echo "🔎 Buscando documento de teste ..."
curl -fsSL "${auth_args[@]}" -XGET "$OPENSEARCH_URL/test-index/_search?pretty"

echo "🔎 Deletando índice de teste ..."
curl -fsSL "${auth_args[@]}" -XDELETE "$OPENSEARCH_URL/test-index"
hr

# 3. Teste de Index Templates
echo "🔎 Verificando index templates aplicados..."
for tpl in default-templates logs-template metrics-template; do
  if curl -fsSL "${auth_args[@]}" "$OPENSEARCH_URL/_index_template/$tpl" | grep -q "\"$tpl\""; then
    echo "✅ Template [$tpl] encontrado"
  else
    echo "❌ Template [$tpl] não encontrado!"
    exit 1
  fi
done
hr

# 4. Teste de Pipelines
echo "🔎 Verificando ingest pipelines aplicados..."
for pipe in logs-pipelines normalize-timestamp; do
  if curl -fsSL "${auth_args[@]}" "$OPENSEARCH_URL/_ingest/pipeline/$pipe" | grep -q "\"$pipe\""; then
    echo "✅ Pipeline [$pipe] encontrado"
  else
    echo "❌ Pipeline [$pipe] não encontrado!"
    exit 1
  fi
done
hr

# 5. Teste do Dashboards
echo "🔎 Testando OpenSearch Dashboards em $DASHBOARDS_URL ..."
dash_status=$(curl -fsSL "$DASHBOARDS_URL/api/status")
if echo "$dash_status" | grep -q '"state":"green"'; then
  echo "✅ Dashboards saudável!"
else
  echo "❌ Dashboards não está saudável!"
  exit 1
fi

hr
echo "🎉 Todos os testes passaram!"
