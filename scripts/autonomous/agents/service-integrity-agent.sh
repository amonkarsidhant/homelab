#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

REPO_CHECK="$ROOT_DIR/scripts/service-integrity-check.sh"
LIVE_CHECK="$HOME/scripts/service-integrity-check.sh"

if [ -x "$REPO_CHECK" ]; then
  "$REPO_CHECK"
  exit 0
fi

if [ -x "$LIVE_CHECK" ]; then
  "$LIVE_CHECK"
  exit 0
fi

echo "No service integrity check script found."
echo "Expected one of:"
echo "- $REPO_CHECK"
echo "- $LIVE_CHECK"
exit 2
