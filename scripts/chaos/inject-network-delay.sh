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

"$SCRIPT_DIR/annotate-grafana.sh" "CHAOS START" "Network delay ${DELAY_MS}ms on $TARGET for ${DURATION}s"
echo "Injecting ${DELAY_MS}ms delay into $TARGET for ${DURATION}s"

docker run --rm -i \
  --network host \
  -v /var/run/docker.sock:/var/run/docker.sock \
  ghcr.io/alexei-led/pumba:latest \
  --log-level info \
  netem --duration "${DURATION}s" delay --time "$DELAY_MS" "re2:^${TARGET}$"

"$SCRIPT_DIR/annotate-grafana.sh" "CHAOS END" "Network delay test finished for $TARGET"
echo "Network delay experiment complete"
