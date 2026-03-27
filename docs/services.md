# Services

All 18 services running in the homelab.

## Core Infrastructure

### Traefik
Reverse proxy with automatic TLS via Let's Encrypt (Cloudflare DNS-01).

- **Location**: `traefik/`
- **Docs**: [Rebuild Guide](rebuild/SERVICES.md#1-traefik-reverse-proxy--tls)

### Authelia
SSO provider protecting all authenticated services.

- **Location**: `authelia/`
- **Docs**: [Rebuild Guide](rebuild/SERVICES.md#2-authelia--sso-provider)

## Source Control & CI

### Gitea
Self-hosted Git hosting with full GitHub-compatible API.

- **URL**: https://gitea.homelabdev.space
- **Location**: `gitea/`

### Act Runner
GitHub Actions-compatible CI/CD runner for automated pipelines.

- **Location**: `act-runner/`

## Observability

### Prometheus
Metrics collection and alerting engine.

- **Location**: `observability/`

### Grafana
Dashboards and visualization for all metrics.

- **URL**: https://observability.homelabdev.space
- **Location**: `observability/grafana-provisioning/`

### Loki
Log aggregation system.

- **Location**: `observability/`

### Jaeger
Distributed tracing for request flow analysis.

- **Location**: `observability/`

### Alertmanager
Alert routing, deduplication, and silencing.

- **Location**: `observability/`

## Developer Experience

### Backstage
Developer portal with service catalog, templates, and docs.

- **URL**: https://backstage.homelabdev.space
- **Location**: `backstage/`
- **Catalog**: `backstage/catalog/`

### Goalert
On-call alerting and incident management.

- **URL**: https://goalert.homelabdev.space
- **Location**: `goalert/`

### Code Server
Cloud IDE — VS Code in your browser.

- **URL**: https://code.homelabdev.space
- **Location**: `code-server/`

### Homarr
Dashboard for all services.

- **URL**: https://home.homelabdev.space
- **Location**: `homarr/`

## Automation

### n8n
Workflow automation for ops tasks, alerting, and integrations.

- **URL**: https://ai.homelabdev.space
- **Location**: `n8n/`
- **Workflows**: `n8n/workflows/`

## Security

### Vaultwarden
Password manager and secrets vault.

- **URL**: https://vault.homelabdev.space
- **Location**: `vaultwarden/`
- **Docs**: [Admin Guide](vaultwarden-admin-user-guide.md)

## AI

### Open WebUI
Chat interface for AI models via LiteLLM.

- **URL**: https://chat.homelabdev.space
- **Location**: `chat-ui/`

### LiteLLM
AI gateway providing unified access to 15+ LLM providers.

- **Location**: `ai-gateway/`

### Nestra Home OS (SaaS Bootstrap)
Early-stage smart-home orchestration product stack.

- **Web**: https://nestra.homelabdev.space
- **API**: https://api.nestra.homelabdev.space
- **Auth**: https://auth.nestra.homelabdev.space
- **Location**: `nestra/`

## Communication

### Mailserver
Self-hosted email server with IMAP/SMTP.

- **URL**: https://mail.homelabdev.space
- **Location**: `mailserver/`
