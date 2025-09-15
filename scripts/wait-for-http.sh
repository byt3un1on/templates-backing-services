#!/usr/bin/env bash
set -e

URL=${1:-http://localhost:9200/_cluster/health}
echo "⏳ Esperando serviço responder em $URL"

for i in {1..5}; do
  if curl -fsS "$URL" > /dev/null; then
    echo "✅ Serviço disponível!"
    exit 0
  fi
  echo "Tentativa $i falhou, aguardando..."
  sleep 5
done

echo "❌ Timeout esperando $URL"
exit 1