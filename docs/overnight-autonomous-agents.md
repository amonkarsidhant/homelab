# Overnight Autonomous Agents

This package runs a set of autonomous homelab agents overnight and stores timestamped reports.

## What it runs

- `service_integrity`: runs the existing integrity check script.
- `config_drift`: compares repo-managed config with live config.
- `container_health`: detects unhealthy/restarting/dead containers.
- `tls_sentinel`: validates HTTPS and certificates for critical hosts.

## Paths

- Runner: `scripts/autonomous/overnight-agent-runner.sh`
- Agents: `scripts/autonomous/agents/*.sh`
- TLS host list: `scripts/autonomous/config/hosts.txt`
- Logs: `~/logs/autonomous-agents/<UTC timestamp>/`
- Latest run symlink: `~/logs/autonomous-agents/latest`

## Usage

Run once:

```bash
./scripts/autonomous/overnight-agent-runner.sh
```

Install overnight schedule:

```bash
./scripts/autonomous/install-cron.sh
```

Remove schedule:

```bash
./scripts/autonomous/uninstall-cron.sh
```

## Schedule installed by default script

- Every 20 minutes between 22:00 and 06:59.
- One morning summary run at 07:10.

The installer uses `cron` when available. If `crontab` is missing, it automatically installs a `systemd --user` timer.

## Alerts

If `DISCORD_WEBHOOK_URL` is available in `~/.config/homelab/monitor.env`, failed runs send a Discord alert.

## Customizing TLS monitoring

Edit `scripts/autonomous/config/hosts.txt` and add one host per line.
