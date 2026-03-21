# Operations Checklist

Use this checklist to keep the homelab healthy and secure.

## Daily

- Check integrity status:
  - `systemctl status homelab-integrity.timer --no-pager`
  - `ls -1t /home/sidhant/logs/integrity | head -1`
- Check container health:
  - `docker ps --format 'table {{.Names}}\t{{.Status}}'`
- Check Gitea Actions queue and recent runs.
- Confirm there are no critical Discord alerts.

## Weekly

- Run full integrity check manually:
  - `/home/sidhant/scripts/service-integrity-check.sh`
- Confirm weekly chaos drill timer is active:
  - `systemctl status homelab-weekly-chaos.timer --no-pager`
- Check latest chaos report:
  - `ls -1t /home/sidhant/homelab/docs/chaos-reports | head -1`
- Review logs for repeated warnings/errors:
  - `docker logs --since 7d traefik`
  - `docker logs --since 7d gitea`
  - `docker logs --since 7d act-runner`
  - `docker logs --since 7d loki`
- Verify backup freshness:
  - `ls -lh /mnt/data/backups | tail -5`
  - Check MinIO bucket `homelab-backups` has recent archive.
- Validate DNS routes in Cloudflare still match active services.

## Monthly

- Rotate high-risk secrets:
  - Gitea PATs
  - Cloudflare API token
  - SMTP relay credentials
  - CI runner registration token
- Confirm all active secrets exist in Vaultwarden.
- Remove any stale plaintext secrets from disk.
- Review breakglass account access and test one recovery flow.
- Update containers in a controlled PR and verify after deploy.

## Release / Change Checklist (Per PR Merge)

- PR approved and merged to `main`.
- CI passed on merge commit.
- Deployment workflow succeeded.
- Post-deploy checks:
  - `docker ps` all expected services up
  - integrity check returns `BAD=0`
  - key routes respond (`gitea`, `vault`, `grafana`, `auth`)

## Incident Checklist

- Capture scope first: which service, when, user impact.
- Run integrity script and inspect failing section.
- Check Traefik logs for 502/upstream failures.
- Check service-specific logs and mounted data paths.
- If secret/auth issue, rotate secret and update Vaultwarden + runtime env.
- Create a PR with fix + short root cause note.

## Quick Commands

- Integrity check:
  - `/home/sidhant/scripts/service-integrity-check.sh`
- Start/restart stack component:
  - `cd /home/sidhant/<component> && docker-compose up -d`
- Timer status:
  - `systemctl list-timers homelab-integrity.timer --no-pager`
- Latest integrity log:
  - `tail -n 80 /home/sidhant/logs/integrity/$(ls -1t /home/sidhant/logs/integrity | head -1)`
