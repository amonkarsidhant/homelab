# HomeLab Platform

Welcome to the HomeLab developer portal documentation.

## Overview

This homelab is an Azure VM-based platform for delivery automation, observability, and security experimentation. It runs a complete DevOps stack with CI/CD, monitoring, secrets management, and developer experience tools.

## Architecture

The platform consists of:

- **Infrastructure**: Single Azure VM with persistent data volume
- **Edge Layer**: Traefik reverse proxy with TLS termination
- **Security**: Authelia authentication, Vaultwarden secrets
- **CI/CD**: Gitea + Gitea Actions + act-runner
- **Observability**: Prometheus, Grafana, Loki, Jaeger
- **Developer Portal**: Backstage (this portal!)
- **Incident Management**: GoAlert for on-call scheduling

## Quick Links

- [Operations Runbook](homelab-operations-runbook.md)
- [Week 2-4 Roadmap](week2-4-roadmap.md)
- [Backstage Scorecard](backstage-scorecard.md)

## Core Services

### Platform Tier

- **Traefik**: Reverse proxy and ingress controller
- **Gitea**: Git hosting and CI/CD control plane
- **act-runner**: Gitea Actions execution runtime
- **Minio**: Object storage for artifacts and backups
- **Authelia**: SSO and authentication gateway

### Observability Tier

- **Prometheus**: Metrics collection and alerting
- **Grafana**: Dashboards and visualization
- **Loki**: Log aggregation
- **Jaeger**: Distributed tracing

### Developer Experience

- **Backstage**: Service catalog and developer portal
- **GoAlert**: On-call scheduling and escalation

## Getting Started

New to the homelab? Start here:

1. Review the [Operations Runbook](homelab-operations-runbook.md)
2. Check service health in [Grafana](https://grafana.homelabdev.space)
3. View recent deployments in [Gitea Actions](https://gitea.homelabdev.space/sidhant/homelab/actions)
4. Browse the service catalog in Backstage

## Operational Excellence

- **Service Scorecard**: All 13 components maintain 100% quality score
- **CI/CD Integration**: Automated deploy on merge to main
- **Monitoring**: Full observability stack with Prometheus + Grafana
- **Secrets**: Centralized in Vaultwarden
- **Documentation**: TechDocs for all major components

## Support

- **Runbook**: See [homelab-operations-runbook.md](homelab-operations-runbook.md)
- **Incidents**: Escalate via GoAlert
- **Questions**: Check existing docs or create an issue in Gitea
