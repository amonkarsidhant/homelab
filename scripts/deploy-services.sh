#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
VM_HOST="${VM_HOST:-51.143.249.28}"
VM_USER="${VM_USER:-sidhant}"
VM_APP_DIR="${VM_APP_DIR:-/home/sidhant/homelab}"
SSH_OPTS=(-i ~/.ssh/homelab_deploy -o StrictHostKeyChecking=no)

sync_repo() {
  echo "=== Syncing repo to VM ==="
  rsync -az --delete -e "ssh ${SSH_OPTS[*]}" "$REPO_DIR/" "$VM_USER@$VM_HOST:$VM_APP_DIR/"
}

run_remote() {
  local action="$1"
  echo "=== Running remote orchestrator: $action ==="
  ssh "${SSH_OPTS[@]}" "$VM_USER@$VM_HOST" "APP_DIR='$VM_APP_DIR' VM_USER='$VM_USER' bash '$VM_APP_DIR/scripts/vm-deploy-orchestrator.sh' '$action'"
}

run_drift_check() {
  echo "=== Running drift check ==="
  ssh "${SSH_OPTS[@]}" "$VM_USER@$VM_HOST" "APP_DIR='$VM_APP_DIR' bash '$VM_APP_DIR/scripts/config-drift-check.sh' check"
}

case "${1:-deploy}" in
  deploy)
    sync_repo
    run_remote deploy
    run_drift_check
    ;;
  sync)
    sync_repo
    run_remote sync
    ;;
  status)
    run_remote status
    ;;
  drift-check)
    run_drift_check
    ;;
  baseline)
    ssh "${SSH_OPTS[@]}" "$VM_USER@$VM_HOST" "APP_DIR='$VM_APP_DIR' bash '$VM_APP_DIR/scripts/config-drift-check.sh' baseline"
    ;;
  *)
    echo "Usage: $0 {deploy|sync|status|drift-check|baseline}"
    exit 1
    ;;
esac
