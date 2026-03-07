# Week 2-4 Roadmap

This roadmap tracks the next execution phases after the Week 1 automation foundation.

## Week 2: Reliability Hardening + Backstage Foundations

### Platform Reliability

- [ ] remove cross-stack compose ownership conflicts
- [ ] keep deploy orchestration deterministic and non-overlapping
- [ ] add preflight CI checks for compose/service sanity
- [ ] reach 3 consecutive successful deploys on `main`

### Backstage Deliverables

- [ ] normalize catalog metadata across active services (`owner`, `lifecycle`, `dependsOn`)
- [ ] add operational links per service (runbook, checklist, source path)
- [ ] define and apply service readiness metadata (`tier`, `criticality`, `runbook`)

### Definition of Done

- [ ] no duplicate service ownership across compose stacks
- [ ] deploy workflows complete without container-name conflicts
- [ ] Backstage catalog is complete and consistent for all active core services

## Week 3: Security & Compliance Hardening + Backstage Governance

### Platform Security

- [ ] strengthen secret hygiene and rotation flow
- [ ] harden auth paths and least-privilege access patterns
- [ ] enforce practical security checks in CI/CD quality gates

### Backstage Deliverables

- [ ] add governance/security metadata to all service entities
- [ ] link policy docs and incident ownership from catalog entries
- [ ] add CI validation for required Backstage metadata fields

### Definition of Done

- [ ] CI blocks merges when required security/governance checks fail
- [ ] required Backstage governance fields are present for all production services

## Week 4: Observability & Operational Excellence + Backstage Ops Portal

### Platform Operations

- [ ] tune alert quality and reduce noise with GoAlert-centered escalation paths
- [ ] define service reliability indicators and recurring reporting
- [ ] run chaos/recovery drills with explicit pass criteria

### Backstage Deliverables

- [ ] add operations links per service (alerts, logs, traces, runbooks)
- [ ] publish reliability scorecard references per service
- [ ] make Backstage the primary day-2 operations entry point

### Definition of Done

- [ ] incident triage can start from Backstage with no missing critical links
- [ ] weekly operational review can be run from standardized portal-linked sources
