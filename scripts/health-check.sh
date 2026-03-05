#!/bin/bash

set -e

echo "=== Homelab Health Check ==="
echo "Timestamp: $(date)"
echo ""

check_service() {
    local name=$1
    local url=$2
    
    if curl -sf -o /dev/null -w "%{http_code}" "$url" 2>/dev/null | grep -q "200\|301\|302"; then
        echo "✓ $name: UP"
        return 0
    else
        echo "✗ $name: DOWN"
        return 1
    fi
}

FAILED=0

check_service "Traefik" "http://traefik.homelabdev.space" || FAILED=1
check_service "Gitea" "https://gitea.homelabdev.space" || FAILED=1
check_service "Prometheus" "http://prometheus.homelabdev.space" || FAILED=1
check_service "Grafana" "http://grafana.homelabdev.space" || FAILED=1

echo ""
if [ $FAILED -eq 1 ]; then
    echo "Health check FAILED"
    exit 1
else
    echo "All services healthy"
    exit 0
fi
