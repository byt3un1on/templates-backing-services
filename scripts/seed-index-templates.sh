#!/usr/bin/env bash
set -e

OPENSEARCH_URL=${1:-http://localhost:9200}
BOOTSTRAP_DIR="./bootstrap"

apply_file() {
  local type=$1
  local path=$2
  local endpoint=$3

  for file in "$path"/*.json; do
    [ -e "$file" ] || continue
    name=$(basename "$file" .json)
    echo " → $type: $name"

    # Envia para o OpenSearch e captura resposta
    response=$(curl -s -w "\nHTTP %{http_code}\n" -X PUT "$OPENSEARCH_URL/$endpoint/$name" \
      -H 'Content-Type: application/json' \
      -d @"$file")

    echo "$response"
    echo ""
  done
}

echo "📦 Aplicando index templates..."
apply_file "Template" "$BOOTSTRAP_DIR/index-templates" "_index_template"

echo "📦 Aplicando ingest pipelines..."
apply_file "Pipeline" "$BOOTSTRAP_DIR/ingest-pipelines" "_ingest/pipeline"

echo "✅ Templates e pipelines aplicados com sucesso!"
