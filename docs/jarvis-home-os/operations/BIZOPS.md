# BIZOPS.md — JARVIS Home OS Business Operations Setup

**Version:** 0.1.0  
**Owner:** COO (jarvis-coo)  
**BizOps Agent:** jarvis-bizops  
**Effective Date:** March 27, 2026  

---

## 1. Entity Structure Recommendation

### Recommendation: Delaware C-Corporation

**Rationale:** A C-Corporation is the standard choice for a venture-backed or scalable SaaS company. It provides:
- Limited liability protection
- Ability to issue multiple classes of stock (important for investor financing)
- Familiarity to investors, legal counsel, and future acquirers
- Delaware's well-developed corporate law and specialized courts (Chancery Court)

**Alternative considered — LLC:**
- Pros: Pass-through taxation, flexibility, fewer formalities
- Cons: Harder to raise VC funding (VCs prefer C-Corp), less familiar to institutional investors, harder to issue equity compensation

### Early Stage Setup (Sprint 0 — MVP Phase)

**Before incorporation:** Sole proprietorship or no entity yet (operate as individual)

**Timeline for incorporation:** Before first external investment or before hiring first employee

### Entity Structure Details

| Element | Recommendation |
|---------|---------------|
| **State of Incorporation** | Delaware |
| **Entity Type** | C-Corporation |
| **Registered Agent** | Corporation Service Company (CSC) or CT Corporation |
| **Fiscal Year End** | December 31 |
| **Initial Authorized Shares** | 10,000,000 common + 5,000,000 preferred |

### Founders' Equity

| Founder | Role | Equity |
|---------|------|--------|
| Sidhant Amonkar | CEO & Lead Architect | 80% |
| Future co-founders / key hires | TBD | 20% (reserved pool) |

**Note:** Equity vesting: 4-year vest with 1-year cliff, monthly thereafter. Standard reverse triangular merge structure for acqui-hires.

### Intellectual Property

- All IP created by founders and agents must be assigned to the Delaware C-Corp
- Founder IP assignment agreements signed at incorporation
- Agent outputs stored in org memory and file system; IP assignment per agent employment/contractor agreement

---

## 2. Agentic Org Operations

### How the Agentic Org Operates

The JARVIS Home OS org operates as a distributed AI agent team, coordinated via the `.agentic-qe` system and memory store. Each agent persona has a defined mandate and collaborates via structured messages.

### Weekly Sync Cadence

| Day | Meeting | Owner | Participants | Duration | Output |
|-----|---------|-------|-------------|----------|--------|
| Monday | **Weekly Pulse** | COO | All C-suite | 30 min | Status update: what shipped, what's blocked, metrics review |
| Monday | **Incident Review** | COO + CTO | Eng + Support Ops | 30 min | Last week's incidents, PIR status, action items |
| Wednesday | **Sprint Standup** | CEO | All C-suite | 20 min | What are we working on today? |
| Friday | **Decision Log Review** | CEO | All C-suite | 20 min | Decisions made this week, open questions |
| Monthly | **QBR** | CEO | All C-suite + leads | 2 hrs | KPIs, OKR review, strategic adjustments |
| Quarterly | **Board Prep** | CEO | COO + CFO | 4 hrs | Board deck, financials, projections |

### Decision Log

All consequential decisions are documented in `org/decisions/` with the following format:

```
# ADR-[NUMBER] — [Title]

**Date:** [ISO]
**Owner:** [Agent/C-suite]
**Status:** [Proposed / Approved / Superseded by ADR-XXX]
**Severity:** [P0 / P1 / P2]

## Context
[Why this decision was necessary]

## Decision
[What was decided]

## Rationale
[Why this over alternatives]

## Consequences
**Positive:**
- [Consequence 1]

**Negative:**
- [Consequence 1]

## Open Questions
- [Question]
```

### Memory Management

**Shared Memory Store:** `.agentic-qe/memory.db` (SQLite)

| Namespace | Contents | Access |
|-----------|----------|--------|
| `decisions` | All ADRs, strategic choices, documented rationale | All agents read; write by decision owner |
| `metrics` | KPI snapshots, weekly baselines, trend data | All agents read; BizOps agent writes |
| `incidents` | Incident history, PIRs, action items | All agents read; CQO + COO write |
| `product` | Roadmap decisions, feature priorities, user research | CPO + CTO write; all read |
| `sales` | Pipeline, deal status, enterprise conversations | CRO write; CEO + COO read |
| `compliance` | Audit logs, regulatory filings, certifications | Compliance agent write; COO read |
| `learning` | Patterns, anti-patterns, agent performance | All agents read/write |

**Memory Write Protocol:**
1. Agent identifies something worth storing
2. Uses `memory_store` with appropriate namespace
3. Includes `persist: true` for critical information
4. Tags with confidence score (0-1)

**Memory Query Protocol:**
1. Agent uses `memory_query` before making repeated decisions
2. Semantic search for patterns ("how did we handle X in the past?")
3. Glob pattern for specific namespaces (`incidents/*`)

### Agent Spawning Protocol

When a C-suite agent spawns a sub-agent:

1. Define the task clearly in the agent prompt
2. Set `run_in_background: true` for non-urgent tasks
3. Pass context: current ADR state, relevant memory namespace
4. Sub-agent delivers findings → parent agent synthesizes
5. Sub-agent outputs stored in memory by parent agent
6. Never spawn more than 5 concurrent sub-agents per parent

### Org Communication Standards

| Message Type | Use | Example |
|-------------|-----|---------|
| **Finding** | Research, data, analysis delivered upward or cross | "CTO finding: Matter 1.2 spec reveals..." |
| **Challenge** | Blockers, risks, trade-offs raised for deliberation | "CRO challenges: Is the enterprise pricing realistic?" |
| **Consensus** | Decisions reached and documented | "CPO + CTO consensus: Flutter for mobile v0.1" |
| **Escalation** | Unresolved conflicts or strategic calls | "Escalation: Budget conflict between CTO and CPO" |
| **Completion Report** | Task done, summary delivered | "CTO completion: ADR-003 delivered" |

---

## 3. Vendor Contracts

### Cloud Infrastructure — AWS/GCP

| Vendor | Service | Estimated Monthly Cost | Contract Terms |
|--------|---------|----------------------|----------------|
| AWS or GCP | Compute (EC2/GCE), Storage (S3/Cloud Storage), Database (RDS/Cloud SQL), CDN (CloudFront/Cloud CDN), Monitoring | $2K-20K depending on scale | 1-year reserved for compute (30-50% savings); on-demand for storage |

**Contract requirements:**
- Execute via AWS Marketplace or GCP Marketplace (no enterprise MSA needed at early stage)
- Ensure DPA is signed (both offer standard DTAs)
- Enable cost alerts at $5K, $10K, $15K thresholds
- Reserve instances 3 months post-launch when usage is predictable

**Migration path:** AWS ↔ GCP portability via containerized deployment (Docker/Kubernetes)

### SMS / Notifications — Twilio

| Vendor | Service | Estimated Monthly Cost | Contract Terms |
|--------|---------|----------------------|----------------|
| Twilio | SMS verification, 2FA, optional SMS notifications | $200-2K/mo depending on verification volume | Month-to-month via Twilio console; Enterprise MSA before >$10K/mo |

**Contract requirements:**
- Sign DPA for PII handling
- Enable fraud detection (Twilio's Trust Hub)
- Set per-account spend limit to prevent runaway costs

### Billing — Stripe

| Vendor | Service | Estimated Monthly Cost | Contract Terms |
|--------|---------|----------------------|----------------|
| Stripe | Subscription billing, payment processing, invoicing, Stripe Billing | 2.9% + 30¢ per transaction + 0.5% for subscriptions | Stripe's standard online agreement (no MSA needed at early stage); Upgrade to Enterprise when >$1M ARR for dedicated support |

**Contract requirements:**
- Complete Stripe onboarding and identity verification
- Sign Stripe's standard services agreement (online)
- Enable SCA for EU/UK payments (automatic via Stripe)
- Set up Stripe Radar for fraud detection

### Email — SendGrid / Postmark

| Vendor | Service | Estimated Monthly Cost | Contract Terms |
|--------|---------|----------------------|----------------|
| SendGrid | Transactional email, marketing email | $20-200/mo | Month-to-month; Pro plan for dedicated IPs |

**Alternative:** Postmark (higher deliverability, higher price)

**Contract requirements:**
- Sign DPA
- Authenticate domains (SPF, DKIM, DMARC)
- Implement unsubscribe headers (CAN-SPAM, CASL)

### Monitoring — Datadog

| Vendor | Service | Estimated Monthly Cost | Contract Terms |
|--------|---------|----------------------|----------------|
| Datadog | APM, infrastructure monitoring, logs, dashboards, alerting | $500-5K/mo | Annual commitment for 20-30% savings; starter tier at ~$500/mo sufficient for MVP |

**Contract requirements:**
- Trial period first (14 days free)
- Negotiate annual contract before production launch

### Incident Communication — Statuspage / Status.io

| Vendor | Service | Estimated Monthly Cost | Contract Terms |
|--------|---------|----------------------|----------------|
| Statuspage (Atlassian) | Public status page, incident posts, subscriber notifications | $50-200/mo | Month-to-month; Free tier available for <10 incidents/mo |

**Alternative:** Status.io (cheaper, simpler)

### Collaboration — Notion / Linear / Slack

| Vendor | Service | Estimated Monthly Cost | Contract Terms |
|--------|---------|----------------------|----------------|
| Notion | Internal wiki, docs, project tracking | $48-120/mo (team plan) | Annual for 20% savings |
| Linear | Issue tracking, sprint management | $48-160/mo (team plan) | Annual for 20% savings |
| Slack | Team communication | $96-150/mo (pro) | Annual for 20% savings |

**Note:** Consider GitHub Issues + Projects as free alternative to Linear

### Customer Support — Intercom / Zendesk

| Vendor | Service | Estimated Monthly Cost | Contract Terms |
|--------|---------|----------------------|----------------|
| Intercom | In-app chat, email, help center | $74-500/mo | Month-to-month; Essential at $74/mo for early stage |
| Zendesk | Ticket management, support workflows | $55-1K/mo | Month-to-month; Starter at $55/mo for early stage |

**Contract requirements:**
- Trial first
- GDPR DPA required (both offer standard)
- Data processing agreement for EU users

---

## 4. Financial Operations

### Bank Account

- **Recommendation:** Mercury (YC-backed, startup-friendly, FDIC insured, free for early stage)
- Alternative: Silicon Valley Bank (SVB) — once >$250K revenue
- Merchants of record: Stripe handles payment processing; no separate merchant account needed initially

### Accounting

| Area | Tool | Notes |
|------|------|-------|
| **Bookkeeping** | Wave (free) or QuickBooks Online | Wave sufficient until >$500K revenue |
| **Tax filing** | CPA (annual) + TurboTax Business (quarterly estimates) | Annual CPA review required post-revenue |
| **Payroll** | Gusto | For future employees; not needed pre-revenue |
| **Invoicing (Enterprise)** | Stripe Invoicing or Bill.com | For enterprise white-label deals |

### Tax Obligations

| Tax Type | Who Pays | Collected How | Filed When |
|----------|----------|---------------|-----------|
| **Sales tax (US)** | Customer | Collected by Stripe, remitted by JARVIS | Monthly/quarterly |
| **VAT (EU)** | Customer | Collected via Stripe Tax or Quaderno | Monthly |
| **Income tax (US)** | JARVIS (C-Corp) | Estimated quarterly payments | Quarterly + annual |
| **Payroll tax** | Employees | Gusto processes | Payroll periods |

---

## 5. Legal Foundation (MVP Stage)

### Must-Have (Day 1)

| Document | Purpose | Owner |
|---------|---------|-------|
| **Privacy Policy** | Disclose data collection, GDPR/CCPA compliance | COO + external counsel |
| **Terms of Service** | Govern JARVIS usage, liability limitations | COO + external counsel |
| **Cookie Policy** | If using cookies (web properties) | COO + external counsel |
| **DPAs (Data Processing Agreements)** | With all vendors handling personal data | COO |
| **Founder IP Assignment** | Assign all IP to Delaware C-Corp | CEO + external counsel |

### Should-Have (Before External Funding)

| Document | Purpose | Owner |
|---------|---------|-------|
| **Investor Rights Agreement (IRA)** | Rights for lead investor | External counsel |
| **Voting Agreement** | Board composition, voting rights | External counsel |
| **Right of First Refusal** | Investor co-sale rights | External counsel |
| **Stock Purchase Agreement** | Terms of equity financing | External counsel |
| **Board Consent Resolutions** | Authorize founding shares | CEO |

### Enterprise Sales (White-Label)

| Document | Purpose | Owner |
|---------|---------|-------|
| **Master Services Agreement (MSA)** | Enterprise SLA, liability, IP | External counsel |
| **Order Form / SOW** | Specific engagement terms | CRO + external counsel |
| **Data Processing Addendum (DPA)** | GDPR Article 28 compliance | COO + external counsel |
| **SaaS Security Questionnaire** | Enterprise security review | CQO |
| **Business Associate Agreement (BAA)** | HIPAA compliance (if applicable) | COO + external counsel |

---

## 6. Insurance Requirements

| Insurance Type | When Needed | Estimated Cost |
|---------------|------------|----------------|
| **General Liability** | Before first public launch | $500-1K/year |
| **Cyber Liability** | Before collecting user data at scale | $2-5K/year |
| **Directors & Officers (D&O)** | Before external investment | $3-10K/year |
| **Professional Liability (E&O)** | Before offering enterprise services | $2-5K/year |

**Provider:** Hiscox, Coalition, or State Farm for small business  
**Note:** Many investors require D&O before participating in a funding round

---

## 7. Operational Readiness Checklist

### Pre-Launch (MVP)

- [ ] Delaware C-Corp incorporated
- [ ] Bank account opened (Mercury)
- [ ] AWS/GCP account set up with billing alerts
- [ ] Stripe account fully verified and operational
- [ ] Privacy Policy and Terms of Service live
- [ ] DPA signed with all vendors
- [ ] Founder IP assignments signed
- [ ] Cyber liability insurance bound

### Pre-Enterprise Sales

- [ ] MSA template drafted by external counsel
- [ ] Security questionnaire ready (CSA STAR / SIG)
- [ ] SOC 2 Type II gap assessment completed
- [ ] D&O insurance bound
- [ ] Enterprise pricing approved by CEO
