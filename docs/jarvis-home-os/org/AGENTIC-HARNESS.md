# JARVIS Agentic Harness v0.1

This harness is the operating system for the AI-first organization building JARVIS Home OS.

## Purpose
- Turn strategy into execution with role-specific agent ownership
- Keep product, architecture, quality, and GTM aligned every sprint
- Make decisions traceable, testable, and reversible

## Agent Registry
- `ceo-jarvis`: final decision authority, conflict resolution
- `jarvis-cpo`: product vision, PRD, prioritization
- `jarvis-cto`: architecture, implementation standards, integrations
- `jarvis-cro`: GTM, partnerships, pricing, market narrative
- `jarvis-coo`: support, operations, compliance, unit economics
- `jarvis-cqo`: quality gates, threat model, red-team readiness

## Execution Loop (Weekly)
1. **Monday: Alignment Brief**
   - CEO posts sprint objective and non-negotiables
   - CPO publishes product scope and acceptance criteria
2. **Tuesday-Wednesday: Domain Execution**
   - CTO/CQO run build + risk loops
   - CRO/COO run market + operations loops
3. **Thursday: Cross-Review Council**
   - Each function critiques two others
   - Conflicts logged as decision proposals
4. **Friday: Decision & Release Gate**
   - CQO issues go/no-go
   - CEO resolves unresolved escalations
   - COO publishes weekly ops snapshot

## Artifacts by Function
- **CEO**: `org/DIRECTIVES/*`, final decision log
- **CPO**: `products/PRD.md`, `products/FEATURE-MATRIX.md`
- **CTO**: `tech/ADR-*.md`, `tech/STACK.md`
- **CRO**: `go-to-market/*.md`
- **COO**: `operations/*.md`
- **CQO**: `quality/*.md`

## Decision Protocol
- Decision format: `Context -> Options -> Recommendation -> Risks -> Owner -> Due Date`
- Status values: `proposed`, `accepted`, `rejected`, `revisit-on`
- Tie-break rule: CEO decides only after written dissent from both sides

## Quality Protocol
- No feature reaches release candidate without passing `quality/QUALITY-GATES.md`
- Every high-risk feature requires a red-team scenario update in `quality/RED-TEAM.md`
- Every customer-facing claim must be backed by a measurable KPI in `operations/KPIS.md`

## Output Standards
- No vague status updates; use evidence and explicit trade-offs
- No hidden blockers; escalate if blocked >2 hours
- No irreversible action without CEO sign-off if legal/security/reputation risk exists

## Sprint 1 Entry Criteria
- Sprint 0 docs complete across all 5 functions
- Compelling homeowner value proposition accepted by CEO
- Architecture and quality gates approved by CTO + CQO
- First GTM narrative and ICP validated by CRO
