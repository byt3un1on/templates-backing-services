#!/usr/bin/env bash
set -e

if [ -f ".env" ]; then
  echo "⚠️  Arquivo .env já existe, não vou sobrescrever."
  exit 0
fi

cp .env.example .env

# Sorteia um nome único para cluster
sed -i "s/CLUSTER_NAME=.*/CLUSTER_NAME=opensearch-$(date +%s)/" .env

echo "✅ Arquivo .env gerado com sucesso!"