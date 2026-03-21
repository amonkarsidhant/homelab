# n8n Workflow Automation

n8n is a powerful workflow automation tool for your homelab.

## URLs

- **n8n UI**: https://n8n.homelabdev.space

## First-Time Setup

1. Deploy n8n via the orchestrator or manually start:
   ```bash
   cd /home/sidhant/n8n
   docker compose up -d
   ```

2. Access n8n UI at https://n8n.homelabdev.space

3. Create your admin account on first login

## Workflows

Import these from `workflows/` directory:

### 1. Homelab Ops Alerts (`01-homelab-ops-alerts.json`)
Monitors homelab services every 5 minutes and sends Discord alerts if any are down.

**Requires**:
- Discord webhook credential (create in Discord channel settings)

### 2. Scheduled Backups (`02-scheduled-backups.json`)
Runs daily at 2 AM to backup:
- Backstage PostgreSQL database
- Gitea repositories
- Observability data (Prometheus, Loki, Grafana)

**Requires**:
- PostgreSQL connection for logging backup records
- `/backups` directory on host

### 3. Weekly Status Report (`03-daily-status-report.json`)
Sends weekly report every Monday at 8 AM with:
- Container status
- Disk/memory usage
- Uptime
- HTTP health checks for all services

**Requires**:
- Discord webhook credential

### 4. GitOps Automation (`04-gitops-automation.json`)
Every 6 hours:
- Checks for workflow failures in homelab repo
- Notifies of pending git changes

**Requires**:
- Gitea API token (generate in Gitea settings)

## Credential Setup

In n8n UI → Credentials:

1. **Discord Webhook** (for alerts/reports):
   - Create Incoming Webhook in Discord channel
   - Add as HTTP Header Auth credential in n8n

2. **Gitea API Token** (for GitOps):
   - Generate in Gitea → Settings → Applications → Generate Token
   - Add as HTTP Header Auth in n8n

## Service Discovery in Workflows

Homelab services are available at these internal hostnames:

- `traefik`
- `gitea:3000`
- `act-runner:2376`
- `prometheus:9090`
- `grafana:3000`
- `loki:3100`
- `jaeger:16686`
- `backstage:7007`
- `goalert:8081`
- `minio:9000`

## Troubleshooting

### Workflows not triggering
- Check n8n logs: `docker logs n8n`
- Verify credentials are set
- Check schedule trigger syntax

### Discord alerts not sending
- Verify webhook URL is correct
- Check Discord channel has webhook permissions

### Backup failures
- Ensure `/backups` directory exists on host
- Check PostgreSQL credentials in goalert container

## Integration with Homelab

n8n can be extended with more workflows:

- **Incident Management**: Connect to GoAlert for on-call routing
- **Monitoring**: Query Prometheus/Loki for anomalies
- **GitOps**: Trigger deployments based on workflow completion
- **Notifications**: Email, Slack, Telegram, SMS via various nodes
