# Week 2 Reliability Hardening

This document defines the Week 2 execution track.

## Goals

- remove cross-stack service ownership conflicts
- reduce deploy failures caused by duplicate container names
- add stronger release checks before merge/deploy

## Scope

Week 2 focuses on operational reliability in CI/CD and runtime compose ownership.

### 1) Compose Ownership Split

- `traefik/docker-compose.yml` owns only ingress and edge storage services:
  - `traefik`
  - `minio`
- `observability/docker-compose.yml` owns monitoring and telemetry services:
  - `prometheus`
  - `grafana`
  - `loki`
  - `promtail`
  - `jaeger`
  - `cadvisor`
  - `alertmanager`

### 2) Deploy Reliability

- keep deploy orchestration deterministic through `scripts/vm-deploy-orchestrator.sh`
- ensure startup targets do not overlap across compose stacks

### 3) Quality Gate Expansion

- add and enforce practical CI checks that validate shell scripts and compose integrity
- keep checks non-interactive and runner-safe

### 4) Backstage Catalog Reliability

- normalize core component metadata and dependencies
- add a consistent service-readiness annotation convention
- ensure each core component links to operational guidance

## Started Work

- Removed observability service definitions from `traefik/docker-compose.yml` so containers are defined in one stack only.
- Existing orchestrator startup flow already starts observability from `observability/docker-compose.yml`.
- Added `scripts/ci-preflight.sh` and wired it into `.gitea/workflows/ci.yml` lint stage to fail early on compose ownership overlap and shell syntax issues.
- Normalized `backstage/catalog/all.yaml` with core service annotations (`tier`, `criticality`, `runbook`) and stronger operations/source links.
- Strengthened `scripts/vm-deploy-orchestrator.sh` verification to assert expected containers and key Traefik routes before declaring deploy success.

## Completion Criteria

- deploy workflow succeeds on `main` without container-name conflicts
- no duplicate service ownership across compose stacks
- CI includes meaningful pre-merge checks beyond placeholders
