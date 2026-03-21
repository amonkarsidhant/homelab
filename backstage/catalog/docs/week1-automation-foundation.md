# Week 1 Automation Foundation

This document defines the Week 1 operational baseline:

- one deploy orchestrator used by both CI and manual runs
- deterministic sync from repo-managed files to live service directories
- config drift detection against repo and optional baseline hash manifest

## Unified Deploy Controller

Use `scripts/vm-deploy-orchestrator.sh` on the VM.

Actions:

- `deploy`: full setup + sync + env bootstrap + service start + verify
- `sync`: setup + sync + env bootstrap (no restart)
- `start`: start managed services only
- `verify`: uptime + commit + container status
- `status`: container status only

Example:

```bash
APP_DIR=/home/sidhant/homelab bash scripts/vm-deploy-orchestrator.sh deploy
```

## Manual Operations

Use `scripts/deploy-services.sh` from your workstation.

Actions:

- `deploy`: rsync repo -> run orchestrator `deploy` -> run drift check
- `sync`: rsync repo -> run orchestrator `sync`
- `status`: show container status
- `drift-check`: run drift check only
- `baseline`: refresh drift baseline hash manifest

## Drift Detection

Use `scripts/config-drift-check.sh` on the VM.

Modes:

- `check`: compare repo-managed config to live runtime files and compare live hashes to baseline (if present)
- `baseline`: write live hash baseline to `/home/sidhant/.homelab-drift-baseline.sha256`

Example:

```bash
APP_DIR=/home/sidhant/homelab bash scripts/config-drift-check.sh check
APP_DIR=/home/sidhant/homelab bash scripts/config-drift-check.sh baseline
```

## Scope of Managed Files

The orchestrator and drift checker manage:

- `traefik/`
- `gitea/`
- `act-runner/`
- `observability/`
- `backstage/`
- `goalert/`
- `scripts/service-integrity-check.sh`

Runtime secret files like `.env` are intentionally not overwritten when already present.

## Alertmanager Token Handling

- `observability/alertmanager.yml` uses `${GOALERT_PROM_ALERT_TOKEN}`.
- Runtime value is provided via `/home/sidhant/observability/.env`.
- Template for new environments is `observability/.env.example`.
