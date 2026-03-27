# AGENTS.md — Nestra Product + Engineering Memory

## Mission
You are building Nestra into a world-class SaaS platform, starting from the `nestra/` bootstrap in this repository.

Nestra is not a generic smart-home toy.
It is a privacy-first ambient home intelligence platform that can operate in 3 modes:
1. self-hosted for advanced households,
2. managed SaaS for remote fleet operations,
3. white-label for partners and brands.

The platform direction is:
- predictable automations, not magic behavior,
- guardrails before autonomy,
- privacy and local resilience by default,
- premium UX,
- observable and operable from day 1,
- architecture that can scale from one household to many tenants.

## Current repo truth
Treat the current `nestra/` folder as a bootstrap, not as a finished architecture.
Assume:
- web is currently a lightweight landing/bootstrap surface,
- api is currently a minimal FastAPI service,
- auth is currently a minimal FastAPI auth bootstrap,
- deployment is currently Docker Compose behind Traefik,
- the repo already has strong homelab / infra DNA and should preserve operability.

Do not pretend mature SaaS capabilities already exist if they do not.
Call gaps out clearly and propose the correct foundation.

## Product north star
Nestra should become the control layer between:
- household identities,
- homes / properties,
- residents and roles,
- devices and integrations,
- routines / automations / policies,
- notifications / incidents / audit events,
- partner or installer operations.

The product should eventually support:
- household accounts and orgs,
- tenant isolation,
- role-based access,
- device inventory,
- policy engine / guardrails,
- automation orchestration,
- event history and auditability,
- onboarding flows,
- billing-ready boundaries,
- support and observability,
- white-label / partner surfaces.

## Architectural intent
Prefer a modular SaaS architecture with explicit boundaries.

Target domains:
- identity and access
- tenant and household management
- device registry / connector layer
- automation / orchestration engine
- policy / guardrails engine
- notifications and activity history
- admin / partner operations
- observability / audit / support

Default assumptions:
- backend APIs should be contract-first
- data models should be explicit
- auth should be standards-based
- audit trails should exist for critical actions
- secrets never live in source
- every new subsystem must have health checks, logs, and runbook notes

## Delivery principles
When asked to build something:
1. First reconstruct context from the repository.
2. Then produce a short execution brief before coding:
   - current state
   - target state
   - affected files
   - risks / assumptions
3. Then implement in small, reviewable steps.
4. After changes, update docs for any architectural decision that matters.

## Non-negotiable engineering standards
- No fake enterprise language without concrete implementation.
- No placeholder endpoints unless clearly marked and justified.
- No hidden coupling between web, api, and auth.
- No breaking changes without explaining impact.
- No new dependency without reason.
- No auth shortcuts in code that will later become security debt.
- No “magic” automations without policy and auditability.

## UX standards
Nestra should feel premium, calm, and trustworthy:
- clear copy
- no clutter
- no gimmicky AI framing
- confidence through transparency
- safe defaults
- explainable automation behavior

## Decision rules
If there is tension:
1. security and tenant safety
2. product clarity
3. operability
4. developer ergonomics
5. implementation speed

## Every feature proposal must answer
- who is the actor?
- what tenant / household boundary applies?
- what data model changes are needed?
- what auth / permission checks are needed?
- what audit events are needed?
- how is it observed and debugged?
- how does it fail safely?
- what is the smallest shippable slice?

## Required output format for substantial tasks
For any feature larger than a trivial fix, respond in this order:
1. Repo context summary
2. Proposed design
3. File plan
4. Implementation
5. Validation
6. Follow-up improvements

## Paths to inspect first on startup
- `README.md`
- `nestra/README.md`
- `nestra/docker-compose.yml`
- `nestra/web/`
- `nestra/api/`
- `nestra/auth/`
- any docs related to architecture, auth, observability, CI/CD, and rebuild

## Long-term target
Build Nestra as a credible SaaS product that could stand beside premium smart-home and home-OS platforms:
- beautiful user experience
- disciplined platform architecture
- real identity model
- real tenancy model
- partner-grade operations
- self-hosted + managed SaaS coexistence
- strong reliability and observability
