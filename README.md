# HomeLab

Homelab infrastructure repo for Gitea, CI/CD, observability, auth, and operations.

## Documentation
- Vaultwarden admin/user guide: `docs/vaultwarden-admin-user-guide.md`
- Homelab operations runbook: `docs/homelab-operations-runbook.md`
- Homelab architecture: `docs/homelab-architecture.md`
- Operations checklist: `docs/operations-checklist.md`
- Chaos engineering guide: `docs/chaos-engineering.md`
- Backstage dev portal guide: `docs/backstage-dev-portal.md`
- Week 1 automation foundation: `docs/week1-automation-foundation.md`
- Week 2 reliability hardening: `docs/week2-reliability-hardening.md`
- Week 2-4 roadmap: `docs/week2-4-roadmap.md`
- Backstage Cortex-inspired portal plan: `docs/backstage-cortex-inspired-portal.md`

## Key Scripts
- Integrity check: `scripts/service-integrity-check.sh`
- Integrity monitor (Discord alerts): `scripts/service-integrity-monitor.sh`
- Service health check: `scripts/health-check.sh`
- VM deploy orchestrator: `scripts/vm-deploy-orchestrator.sh`
- Config drift check: `scripts/config-drift-check.sh`
- CI preflight checks: `scripts/ci-preflight.sh`
- Backstage catalog validator: `scripts/backstage-catalog-validate.sh`
- Backstage scorecard generator: `scripts/backstage-scorecard.sh`
- Chaos control CLI: `scripts/chaos/chaosctl.sh`
- Chaos reporting installer: `scripts/chaos/install-grafana-reporting-dashboard.sh`
- Weekly chaos drill installer: `scripts/chaos/install-weekly-drill.sh`
