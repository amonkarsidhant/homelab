#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
HOST_FILE="$ROOT_DIR/scripts/autonomous/config/hosts.txt"

if [ ! -f "$HOST_FILE" ]; then
  echo "Missing hosts file: $HOST_FILE"
  exit 2
fi

if ! command -v openssl >/dev/null 2>&1; then
  echo "openssl command not found"
  exit 2
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "curl command not found"
  exit 2
fi

failures=0

while IFS= read -r host; do
  host="${host%%#*}"
  host="$(printf '%s' "$host" | xargs)"
  [ -z "$host" ] && continue

  if ! curl -sS --head --max-time 20 "https://$host" >/dev/null; then
    echo "BAD: HTTPS request failed for $host"
    failures=$((failures + 1))
    continue
  fi

  cert_info=$(openssl s_client -servername "$host" -connect "$host:443" </dev/null 2>/dev/null | openssl x509 -noout -subject -issuer -enddate)
  subject_line=$(printf '%s\n' "$cert_info" | grep '^subject=')
  issuer_line=$(printf '%s\n' "$cert_info" | grep '^issuer=')
  enddate_line=$(printf '%s\n' "$cert_info" | grep '^notAfter=')

  if printf '%s' "$subject_line" | grep -qi 'TRAEFIK DEFAULT CERT'; then
    echo "BAD: Default Traefik cert still served for $host"
    failures=$((failures + 1))
    continue
  fi

  echo "OK: $host"
  echo "  $subject_line"
  echo "  $issuer_line"
  echo "  $enddate_line"
done < "$HOST_FILE"

if [ "$failures" -gt 0 ]; then
  echo "TLS sentinel failures: $failures"
  exit 1
fi

echo "TLS sentinel checks passed"
