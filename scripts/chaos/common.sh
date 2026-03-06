#!/usr/bin/env bash
set -euo pipefail

PROTECTED_SERVICES=(traefik authelia vaultwarden)

require_docker() {
  if ! command -v docker >/dev/null 2>&1; then
    echo "docker is required"
    exit 1
  fi
}

is_protected_service() {
  local target="$1"
  local svc
  for svc in "${PROTECTED_SERVICES[@]}"; do
    if [[ "$svc" == "$target" ]]; then
      return 0
    fi
  done
  return 1
}

guard_target() {
  local target="$1"
  local force="${2:-false}"

  if ! docker ps --format '{{.Names}}' | grep -qx "$target"; then
    echo "Target container '$target' is not running"
    exit 1
  fi

  if is_protected_service "$target" && [[ "$force" != "true" ]]; then
    echo "Refusing to target protected service '$target' without --force"
    exit 1
  fi
}

require_ack() {
  if [[ "${CHAOS_ACK:-}" != "I_UNDERSTAND" ]]; then
    echo "Set CHAOS_ACK=I_UNDERSTAND to run fault injection"
    exit 1
  fi
}
