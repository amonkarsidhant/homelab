#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<EOF
Usage:
  $0 list
  $0 observe
  $0 install-reporting
  $0 annotate <title> <text>
  $0 stop <container> <seconds> [--force]
  $0 delay <container> <seconds> <delay-ms> [--force]

Examples:
  CHAOS_ACK=I_UNDERSTAND $0 stop gitea 20
  CHAOS_ACK=I_UNDERSTAND $0 delay gitea 30 250
EOF
}

cmd="${1:-}"

case "$cmd" in
  list)
    docker ps --format 'table {{.Names}}\t{{.Status}}'
    ;;
  observe)
    echo "Grafana: https://grafana.homelabdev.space"
    echo "Chaos Control Center: https://grafana.homelabdev.space/d/chaos-center"
    echo "Chaos Reporting: https://grafana.homelabdev.space/d/chaos-reporting"
    echo "Prometheus: https://prometheus.homelabdev.space"
    echo "Jaeger: https://jaeger.homelabdev.space"
    echo "Integrity logs: /home/sidhant/logs/integrity"
    ;;
  install-reporting)
    "$SCRIPT_DIR/install-grafana-dashboard.sh"
    "$SCRIPT_DIR/install-grafana-reporting-dashboard.sh"
    ;;
  annotate)
    shift
    "$SCRIPT_DIR/annotate-grafana.sh" "${1:-CHAOS}" "${2:-manual annotation}"
    ;;
  stop)
    shift
    "$SCRIPT_DIR/inject-stop.sh" "$@"
    ;;
  delay)
    shift
    "$SCRIPT_DIR/inject-network-delay.sh" "$@"
    ;;
  *)
    usage
    exit 1
    ;;
esac
