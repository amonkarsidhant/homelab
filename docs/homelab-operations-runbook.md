# Homelab Operations Runbook

This runbook documents daily operations, integrity monitoring, breakglass access, and recovery flow for the homelab.

## Service Inventory

Core services:
- `traefik`
- `gitea`
- `act-runner`
- `authelia`
- `vaultwarden`
- `code-server`
- `minio`
- `prometheus`
- `grafana`
- `loki`
- `promtail`
- `jaeger`
- `mailserver`

Data root:
- `/mnt/data/*`

## Integrity Monitoring

Scripts:
- Check script: `/home/sidhant/scripts/service-integrity-check.sh`
- Monitor wrapper: `/home/sidhant/scripts/service-integrity-monitor.sh`

Manual run:
```bash
/home/sidhant/scripts/service-integrity-check.sh
```

Interpretation:
- `OK`: healthy
- `WARN`: non-fatal issue
- `BAD`: critical issue, script exits non-zero

## Automated Integrity Alerts

Systemd user units:
- `homelab-integrity.service`
- `homelab-integrity.timer`

Timer schedule:
- Hourly (`OnCalendar=hourly`)

Log location:
- `/home/sidhant/logs/integrity/`

Alert channel:
- Discord webhook via `~/.config/homelab/monitor.env`
- Gitea Actions secret `DISCORD_WEBHOOK_URL` for CI/CD notifications

Expected env file:
```bash
DISCORD_WEBHOOK_URL=<webhook-url>
```

## Breakglass Access Mapping

Authelia:
- `admin` -> `amonkarsidhant@outlook.com`
- `sidhant` -> `amonkarsidhant@gmail.com`

Gitea:
- `sidhant` (admin) -> `amonkarsidhant@outlook.com`
- `breakglass_gmail` (admin) -> `amonkarsidhant@gmail.com`

Grafana:
- OAuth admin: `amonkarsidhant@outlook.com`
- Local breakglass admin: `breakglass_gmail` -> `amonkarsidhant@gmail.com`

Vaultwarden:
- Primary account: `amonkarsidhant@outlook.com`
- Recommended: create secondary account for `amonkarsidhant@gmail.com`

## Incident Response

### 1) Service 502/Bad Gateway
1. Check status: `docker ps`
2. Check reverse proxy logs: `docker logs traefik --tail 200`
3. Check target service logs: `docker logs <service> --tail 200`
4. Run integrity check script
5. Fix mount/path errors first

### 2) Repo Broken in Gitea
1. Verify repo path in container:
   - `/data/git/repositories/<owner>/<repo>.git`
2. Verify `gitea` volume mounts only include `/mnt/data/gitea:/data`
3. Recreate container after compose fix

### 3) Loki Permission Errors
1. Fix ownership:
   ```bash
   sudo chown -R 10001:10001 /mnt/data/loki
   ```
2. Restart Loki

### 4) Act Runner Unauthorized
1. Confirm Traefik bypass route for `PathPrefix(/api/actions)`
2. Check runner token in `/home/sidhant/act-runner/.env`
3. Restart runner

## Backups

Backup script:
- `/home/sidhant/scripts/backup-data.sh`

Schedule:
- Daily at 02:00 UTC (systemd timer)

Target:
- Local archives in `/mnt/data/backups`
- Uploaded to MinIO bucket `homelab-backups`

## Security Notes

- Keep secrets in Vaultwarden; avoid plaintext in git-tracked files.
- Keep `SIGNUPS_ALLOWED=false` for Vaultwarden.
- Rotate tokens/passwords after incidents.
- Keep Cloudflare DNS records aligned with active services.
