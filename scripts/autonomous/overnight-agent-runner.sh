#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
AGENT_DIR="$ROOT_DIR/scripts/autonomous/agents"
LOG_ROOT="${LOG_ROOT:-$HOME/logs/autonomous-agents}"
ENV_FILE="${ENV_FILE:-$HOME/.config/homelab/monitor.env}"
LOCAL_ENV_FILE="$ROOT_DIR/scripts/autonomous/.env"
RUNNER_EXIT_ON_FAILURE="${RUNNER_EXIT_ON_FAILURE:-0}"
RUN_STAMP="$(date -u +%Y%m%d-%H%M%S)"
RUN_DIR="$LOG_ROOT/$RUN_STAMP"
SUMMARY_FILE="$RUN_DIR/summary.md"

mkdir -p "$RUN_DIR"

if [ -f "$ENV_FILE" ]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
fi

if [ -f "$LOCAL_ENV_FILE" ]; then
  # shellcheck disable=SC1090
  source "$LOCAL_ENV_FILE"
fi

log() {
  printf '[runner] %s\n' "$1"
}

append_summary() {
  printf '%s\n' "$1" >> "$SUMMARY_FILE"
}

send_discord_alert() {
  local title="$1"
  local body="$2"

  if [ -z "${DISCORD_WEBHOOK_URL:-}" ]; then
    return 0
  fi

  local escaped
  escaped=$(printf '%s' "$body" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')

  curl -sS -X POST "$DISCORD_WEBHOOK_URL" \
    -H "Content-Type: application/json" \
    -d "{\"embeds\":[{\"title\":\"$title\",\"description\":$escaped,\"color\":15105570}]}" \
    >/dev/null || true
}

run_agent() {
  local name="$1"
  local script="$2"
  local logfile="$RUN_DIR/${name}.log"

  append_summary "## ${name}"
  append_summary "- started: $(date -u '+%Y-%m-%d %H:%M:%SZ')"

  set +e
  "$script" >"$logfile" 2>&1
  local status=$?
  set -e

  if [ "$status" -eq 0 ]; then
    append_summary "- status: PASS"
  else
    append_summary "- status: FAIL (exit $status)"
  fi

  append_summary "- log: $logfile"
  append_summary ""

  return "$status"
}

append_summary "# Overnight Autonomous Agent Run"
append_summary "- host: $(hostname)"
append_summary "- utc: $(date -u '+%Y-%m-%d %H:%M:%SZ')"
append_summary "- run_dir: $RUN_DIR"
append_summary ""

declare -a AGENTS=(
  "service_integrity:$AGENT_DIR/service-integrity-agent.sh"
  "config_drift:$AGENT_DIR/config-drift-agent.sh"
  "container_health:$AGENT_DIR/container-health-agent.sh"
  "tls_sentinel:$AGENT_DIR/tls-sentinel-agent.sh"
  "backup:$AGENT_DIR/backup-agent.sh"
)

failures=0

for entry in "${AGENTS[@]}"; do
  name="${entry%%:*}"
  script="${entry#*:}"

  if [ ! -x "$script" ]; then
    log "Missing executable agent: $script"
    append_summary "## ${name}"
    append_summary "- status: FAIL (agent missing: $script)"
    append_summary ""
    failures=$((failures + 1))
    continue
  fi

  if ! run_agent "$name" "$script"; then
    failures=$((failures + 1))
  fi
done

append_summary "## Final"
if [ "$failures" -eq 0 ]; then
  append_summary "- result: PASS"
  append_summary "- failed_agents: 0"
  log "All agents passed"
else
  append_summary "- result: FAIL"
  append_summary "- failed_agents: $failures"
  log "Detected failures: $failures"
fi

ln -sfn "$RUN_DIR" "$LOG_ROOT/latest"

if [ "$failures" -gt 0 ]; then
  tail_snippet=$(tail -n 40 "$SUMMARY_FILE" | sed 's/"/\\"/g')
  send_discord_alert "Homelab Overnight Agents: FAIL" "$tail_snippet"
  if [ "$RUNNER_EXIT_ON_FAILURE" = "1" ]; then
    exit 1
  fi
fi

exit 0
