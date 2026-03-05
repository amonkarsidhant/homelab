#!/bin/bash

set -e

echo "=== Homelab Health Check ==="
echo "Timestamp: $(date)"
echo ""

FAILED=0

echo "=== Docker Containers ==="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | head -20

echo ""
echo "=== Service Health ==="

check_docker() {
    local name=$1
    if docker ps --format '{{.Names}}' | grep -q "^${name}$"; then
        local status=$(docker ps --filter "name=^${name}$" --format '{{.Status}}')
        if echo "$status" | grep -q "Up"; then
            echo "✓ $name: UP"
            return 0
        else
            echo "✗ $name: $status"
            FAILED=1
            return 1
        fi
    else
        echo "✗ $name: NOT RUNNING"
        FAILED=1
        return 1
    fi
}

check_docker "traefik" || true
check_docker "gitea" || true
check_docker "act-runner" || true
check_docker "prometheus" || true
check_docker "grafana" || true
check_docker "minio" || true
check_docker "authelia" || true

echo ""
if [ $FAILED -eq 1 ]; then
    echo "Health check FAILED"
    exit 1
else
    echo "All services healthy"
    exit 0
fi
