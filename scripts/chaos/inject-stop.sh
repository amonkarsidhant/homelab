#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <container> <duration-seconds> [--force]"
  exit 1
fi

TARGET="$1"
DURATION="$2"
FORCE="false"

if [[ "${3:-}" == "--force" ]]; then
  FORCE="true"
fi

require_docker
require_ack
guard_target "$TARGET" "$FORCE"

EXPERIMENT_ID=$(new_experiment_id)
START_TS=$(now_epoch)

on_error() {
  local end_ts elapsed
  end_ts=$(now_epoch)
  elapsed=$((end_ts - START_TS))
  emit_event "end" "$EXPERIMENT_ID" "stop" "$TARGET" "failed" "$DURATION" "0" "$elapsed"
  "$SCRIPT_DIR/annotate-grafana.sh" "CHAOS FAILED" "Stop experiment failed for $TARGET"
}
trap on_error ERR

"$SCRIPT_DIR/annotate-grafana.sh" "CHAOS START" "Stopping $TARGET for ${DURATION}s"
emit_event "start" "$EXPERIMENT_ID" "stop" "$TARGET" "injected" "$DURATION" "0" "0"
echo "Stopping $TARGET for ${DURATION}s"
docker stop "$TARGET" >/dev/null
sleep "$DURATION"
docker start "$TARGET" >/dev/null
"$SCRIPT_DIR/annotate-grafana.sh" "CHAOS END" "Recovered $TARGET after ${DURATION}s"
END_TS=$(now_epoch)
ELAPSED=$((END_TS - START_TS))
emit_event "end" "$EXPERIMENT_ID" "stop" "$TARGET" "recovered" "$DURATION" "0" "$ELAPSED"
echo "Recovered $TARGET"
trap - ERR
