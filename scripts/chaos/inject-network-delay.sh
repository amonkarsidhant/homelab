#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

if [[ $# -lt 3 ]]; then
  echo "Usage: $0 <container> <duration-seconds> <delay-ms> [--force]"
  exit 1
fi

TARGET="$1"
DURATION="$2"
DELAY_MS="$3"
FORCE="false"

if [[ "${4:-}" == "--force" ]]; then
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
  emit_event "end" "$EXPERIMENT_ID" "delay" "$TARGET" "failed" "$DURATION" "$DELAY_MS" "$elapsed"
  "$SCRIPT_DIR/annotate-grafana.sh" "CHAOS FAILED" "Network delay experiment failed for $TARGET"
}
trap on_error ERR

"$SCRIPT_DIR/annotate-grafana.sh" "CHAOS START" "Network delay ${DELAY_MS}ms on $TARGET for ${DURATION}s"
emit_event "start" "$EXPERIMENT_ID" "delay" "$TARGET" "injected" "$DURATION" "$DELAY_MS" "0"
echo "Injecting ${DELAY_MS}ms delay into $TARGET for ${DURATION}s"

docker run --rm -i \
  --network host \
  -v /var/run/docker.sock:/var/run/docker.sock \
  ghcr.io/alexei-led/pumba:latest \
  --log-level info \
  netem --duration "${DURATION}s" delay --time "$DELAY_MS" "re2:^${TARGET}$"

"$SCRIPT_DIR/annotate-grafana.sh" "CHAOS END" "Network delay test finished for $TARGET"
END_TS=$(now_epoch)
ELAPSED=$((END_TS - START_TS))
emit_event "end" "$EXPERIMENT_ID" "delay" "$TARGET" "recovered" "$DURATION" "$DELAY_MS" "$ELAPSED"
echo "Network delay experiment complete"
trap - ERR
