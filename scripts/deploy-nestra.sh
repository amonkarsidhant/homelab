#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$REPO_ROOT/nestra/.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "[nestra] missing $ENV_FILE"
  echo "[nestra] copy nestra/.env.example to nestra/.env and set AUTH_JWT_SECRET"
  exit 1
fi

echo "[nestra] building and starting stack"
docker compose -f "$REPO_ROOT/nestra/docker-compose.yml" --env-file "$ENV_FILE" up -d --build

echo "[nestra] services started"
echo "- https://nestra.homelabdev.space"
echo "- https://api.nestra.homelabdev.space/health"
echo "- https://auth.nestra.homelabdev.space/health"
