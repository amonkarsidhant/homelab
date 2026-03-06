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

"$SCRIPT_DIR/annotate-grafana.sh" "CHAOS START" "Stopping $TARGET for ${DURATION}s"
echo "Stopping $TARGET for ${DURATION}s"
docker stop "$TARGET" >/dev/null
sleep "$DURATION"
docker start "$TARGET" >/dev/null
"$SCRIPT_DIR/annotate-grafana.sh" "CHAOS END" "Recovered $TARGET after ${DURATION}s"
echo "Recovered $TARGET"
