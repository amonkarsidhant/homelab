# Troubleshooting

Common issues and how to fix them.

## Services Won't Start

```bash
# Check container logs
docker logs <container-name> --tail 50

# Validate compose file
docker compose config

# Check for port conflicts
sudo lsof -i :80 -i :443
```

## TLS/SSL Certificate Issues

```bash
# Check Traefik ACME status
docker exec traefik cat /mnt/data/traefik/acme.json | python3 -m json.tool

# Force cert renewal
docker exec traefik sh -c "kill -HUP 1"
```

## Authelia Login Problems

```bash
# Check Authelia logs
docker logs authelia --tail 50

# Reset user password
docker exec authelia authelia-user reset-password
```

## Container Health Failures

```bash
# Restart a service
cd ~/homelab/<service>
docker compose down && docker compose up -d

# Full restart
docker restart <container-name>
```

## Backup Failures

```bash
# Check backup logs
cat ~/logs/autonomous-agents/latest/backup.log

# Test GPG encryption
echo "test" | gpg --batch --passphrase-fd 0 --symmetric -o /tmp/test.gpg
```

## Disk Space Issues

```bash
# Check disk usage
df -h

# Docker system prune
docker system prune -a --volumes

# Find large files
du -sh /mnt/data/* | sort -rh | head -10
```

## Network/Connectivity Issues

```bash
# Check Traefik routing
docker logs traefik --tail 20

# Test internal DNS
docker exec <container> ping -c 3 gitea
```

## Need More Help?

1. Check [docs/rebuild/SERVICES.md](rebuild/SERVICES.md) for service-specific troubleshooting
2. Check service logs: `docker logs <service> --tail 100`
3. Run integrity check: `bash scripts/service-integrity-check.sh`
