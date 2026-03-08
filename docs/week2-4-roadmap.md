# Week 2-4 Roadmap

This roadmap tracks the next execution phases after the Week 1 automation foundation.

## Week 2: Reliability Hardening + Backstage Foundations

### Platform Reliability

- [x] remove cross-stack compose ownership conflicts (PR #17-20)
- [x] keep deploy orchestration deterministic and non-overlapping (PR #21)
- [x] add preflight CI checks for compose/service sanity (PR #20)
- [x] reach 3 consecutive successful deploys on `main` (achieved)

### Backstage Deliverables

- [x] normalize catalog metadata across active services (`owner`, `lifecycle`, `dependsOn`) (PR #17-20)
- [x] add operational links per service (runbook, checklist, source path) (PR #24-25)
- [x] define and apply service readiness metadata (`tier`, `criticality`, `runbook`) (PR #25)
- [x] **NEW:** Add CI/CD metadata contract (`homelab.dev/gitea-repo`, CI/CD links) (PR #26)
- [x] **NEW:** Implement Cortex-inspired scorecard system (PR #25)
- [x] **NEW:** Achieve 100% catalog quality across all 13 components (PR #26)

### Known Limitations

- **CI/CD Tab Empty**: Stock Backstage image only supports GitHub.com. Gitea Actions require custom plugin.
  - **Workaround**: Use "CI/CD (Gitea Actions)" link in component Links section
  - **Future**: Build custom Gitea Actions plugin or migrate to custom Backstage app (Week 3-4)

### Definition of Done

- [x] no duplicate service ownership across compose stacks
- [x] deploy workflows complete without container-name conflicts
- [x] Backstage catalog is complete and consistent for all active core services
- [x] All 13 components score 1.00 (100%) on operational scorecard

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
