# Chaos Engineering Guide

This guide defines where to observe system behavior and how to inject controlled faults safely.

## Control Plane

- Fault injection scripts: `scripts/chaos/`
- Unified command: `scripts/chaos/chaosctl.sh`
- Observation stack:
  - Grafana: `https://grafana.homelabdev.space`
  - Prometheus: `https://prometheus.homelabdev.space`
  - Jaeger: `https://jaeger.homelabdev.space`
  - Integrity logs: `/home/sidhant/logs/integrity/`

## Install Chaos Dashboard (Observe Place)

Install/update dashboard in Grafana:

```bash
./scripts/chaos/install-grafana-dashboard.sh
```

Dashboard name:
- `Chaos Control Center`

What to watch during experiments:
- service `up` metrics
- scrape duration trends
- alert list
- annotation timeline (`CHAOS START`/`CHAOS END`)

## Safety Guardrails

Fault injection requires explicit acknowledgment:

```bash
export CHAOS_ACK=I_UNDERSTAND
```

Protected services by default:
- `traefik`
- `authelia`
- `vaultwarden`

To target protected services, add `--force`.

## Fault Injection Commands

List running services:

```bash
./scripts/chaos/chaosctl.sh list
```

Show observation links:

```bash
./scripts/chaos/chaosctl.sh observe
```

Inject container stop/restart:

```bash
CHAOS_ACK=I_UNDERSTAND ./scripts/chaos/chaosctl.sh stop gitea 20
```

Inject network delay with Pumba:

```bash
CHAOS_ACK=I_UNDERSTAND ./scripts/chaos/chaosctl.sh delay gitea 30 250
```

Manual annotation only:

```bash
./scripts/chaos/chaosctl.sh annotate "CHAOS NOTE" "manual drill"
```

## Redundancy & Recovery Checks

For each experiment, validate:

1. **Detection**
- Discord alert triggered (if impact is critical)
- Grafana dashboard shows degradation within expected time

2. **Containment**
- Blast radius limited to target service
- No unrelated core services degraded

3. **Recovery**
- Service returns healthy automatically or via runbook
- Integrity check returns `BAD=0`

4. **Data Safety**
- No repository corruption (Gitea)
- No secret/auth breakage (Authelia/Vaultwarden)
- No durable data loss under `/mnt/data`

## Suggested Experiment Sequence

1. `promtail` stop for 15s
2. `jaeger` stop for 15s
3. `gitea` stop for 20s
4. `gitea` 250ms delay for 30s
5. `loki` stop for 20s

Only escalate after each prior test passes.

## After Each Drill

- Run integrity check:

```bash
/home/sidhant/scripts/service-integrity-check.sh
```

- Record in incident notes:
  - detection time
  - recovery time
  - runbook gaps
  - improvement actions
