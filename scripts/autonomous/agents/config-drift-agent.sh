#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
DRIFT_SCRIPT="$ROOT_DIR/scripts/config-drift-check.sh"

if [ ! -x "$DRIFT_SCRIPT" ]; then
  echo "Missing executable drift script: $DRIFT_SCRIPT"
  exit 2
fi

"$DRIFT_SCRIPT" check
