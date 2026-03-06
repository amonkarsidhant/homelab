#!/usr/bin/env bash
set -euo pipefail

PROTECTED_SERVICES=(traefik authelia vaultwarden)

now_epoch() {
  date +%s
}

new_experiment_id() {
  local ts
  ts=$(date -u +%Y%m%dT%H%M%SZ)
  echo "exp-${ts}-${RANDOM}"
}

emit_event() {
  local phase="$1"
  local experiment_id="$2"
  local kind="$3"
  local target="$4"
  local status="$5"
  local duration_sec="${6:-0}"
  local delay_ms="${7:-0}"
  local elapsed_sec="${8:-0}"

  local msg ts
  ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  msg="CHAOS_EVENT phase=${phase} id=${experiment_id} kind=${kind} target=${target} status=${status} duration_sec=${duration_sec} delay_ms=${delay_ms} elapsed_sec=${elapsed_sec}"
  mkdir -p /home/sidhant/logs/chaos
  printf '%s %s\n' "$ts" "$msg" >> /home/sidhant/logs/chaos/events.log
  logger -t chaosctl "$msg"
  echo "$msg"
}

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
