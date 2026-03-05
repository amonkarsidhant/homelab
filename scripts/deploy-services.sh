#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VM_HOST="${VM_HOST:-51.143.249.28}"
VM_USER="${VM_USER:-sidhant}"

echo "=== Homelab Deployment Script ==="
echo "VM: $VM_USER@$VM_HOST"
echo ""

SERVICES=(
    "traefik"
    "gitea"
    "act-runner"
    "observability"
    "authelia"
    "mailserver"
)

deploy_services() {
    echo "=== Syncing service files to VM ==="
    
    for service in "${SERVICES[@]}"; do
        if [ -d "$SCRIPT_DIR/../$service" ]; then
            echo "Syncing $service..."
            rsync -az --delete -e "ssh -i ~/.ssh/homelab_deploy -o StrictHostKeyChecking=no" \
                "$SCRIPT_DIR/../$service/" \
                "$VM_USER@$VM_HOST:/home/sidhant/$service/"
        else
            echo "Warning: $service directory not found, skipping"
        fi
    done
    
    echo ""
    echo "=== Creating required directories on VM ==="
    ssh -i ~/.ssh/homelab_deploy -o StrictHostKeyChecking=no "$VM_USER@$VM_HOST" "
        sudo mkdir -p /mnt/data/{traefik,gitea,act-runner,prometheus,grafana,loki,jaeger,minio,authelia,mailserver}
        sudo chown -R $VM_USER:$VM_USER /mnt/data
        docker network create traefik_default 2>/dev/null || true
    "
    
    echo ""
    echo "=== Starting services ==="
    ssh -i ~/.ssh/homelab_deploy -o StrictHostKeyChecking=no "$VM_USER@$VM_HOST" "
        cd /home/sidhant/traefik && docker-compose up -d
        cd /home/sidhant/gitea && docker-compose up -d
        cd /home/sidhant/act-runner && docker-compose up -d
    "
    
    echo ""
    echo "=== Deployment complete ==="
    ssh -i ~/.ssh/homelab_deploy -o StrictHostKeyChecking=no "$VM_USER@$VM_HOST" "docker ps"
}

status_check() {
    echo "=== Service Status ==="
    ssh -i ~/.ssh/homelab_deploy -o StrictHostKeyChecking=no "$VM_USER@$VM_HOST" "
        echo 'Docker Containers:'
        docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
        echo ''
        echo 'Docker Networks:'
        docker network ls
    "
}

case "${1:-deploy}" in
    deploy)
        deploy_services
        ;;
    status)
        status_check
        ;;
    *)
        echo "Usage: $0 {deploy|status}"
        exit 1
        ;;
esac
