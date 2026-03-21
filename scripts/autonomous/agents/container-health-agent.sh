#!/usr/bin/env bash
set -euo pipefail

if ! command -v docker >/dev/null 2>&1; then
  echo "docker command not found"
  exit 2
fi

issues=0

while IFS='|' read -r name status; do
  [ -z "$name" ] && continue
  if printf '%s' "$status" | grep -Eiq '(unhealthy|restarting|dead|exited)'; then
    echo "BAD: $name -> $status"
    issues=$((issues + 1))
  fi
done < <(docker ps -a --format '{{.Names}}|{{.Status}}')

if [ "$issues" -gt 0 ]; then
  echo "Container health issues detected: $issues"
  exit 1
fi

running=$(docker ps --format '{{.Names}}' | wc -l | tr -d ' ')
echo "Container health OK. Running containers: $running"
