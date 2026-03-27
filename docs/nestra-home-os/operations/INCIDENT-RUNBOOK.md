# INCIDENT-RUNBOOK.md — Nestra Home OS Incident Response Playbook

**Version:** 0.1.0  
**Owner:** COO (nestra-coo)  
**CQO Co-Owner:** Security incidents  
**Effective Date:** March 27, 2026  

---

## 1. Severity Levels

| Severity | Definition | Example | User Impact | Response SLA |
|----------|------------|---------|-------------|--------------|
| **SEV1** | Complete outage — Nestra is fully unavailable for all users, or data loss / confirmed breach | Cloud sync down for all Home+ users; database corruption; ransomware | All users on affected service cannot use Nestra | 15 min — CTO woken up immediately |
| **SEV2** | Major degradation — core functionality broken for >10% of users, or performance degraded >50% | Hub firmware broken causing Matter devices offline; auth service down causing login failures | Significant user impact; users cannot complete key tasks | 30 min — Engineering on-call engaged |
| **SEV3** | Minor degradation — non-core feature broken, or <10% user impact, or self-healing within 1 hour | Skill marketplace slow;少数用户登录问题;单个Matter设备掉线 | Limited user impact; workaround available | 4 hrs — Business hours response |
| **SEV4** | Cosmetic / minor — UI bug, non-blocking performance issue, single user affected | App shows wrong icon; voice command延迟<2s;单个用户设备配对失败 | Minimal impact; no user-facing degradation | Next business day |

**Severity Determination Rules:**
- If unsure between SEV2 and SEV3, treat as SEV2 until更多信息 available
- Any **suspected data breach** is automatically SEV1 regardless of apparent scope
- **Any financial system impact** (Stripe, subscription billing) escalates billing to SEV2 minimum
- **Security incidents** are simultaneously handled by CQO per the security incident process

---

## 2. Response Times by Severity

### SEV1 — Immediate Response

| Milestone | Time | Owner |
|-----------|------|-------|
| Detection / Alert Fire | T+0 | Monitoring (Datadog/PagerDuty) |
| On-call acknowledge | T+5 min | CTO on-call |
| Incident channel created (#inc-YYYY-MM-DD-title) | T+10 min | First responder |
| CTO + COO notified | T+15 min | On-call |
| Root cause identified (initial) | T+30 min | Engineering lead |
| User communication issued | T+45 min | COO |
| Status page updated | T+45 min | Support Ops Agent |
| Resolution or detailed ETA | T+2 hrs | Engineering |
| Resolution confirmed | T+4 hrs target | Engineering + QA |

### SEV2 — Fast Response

| Milestone | Time | Owner |
|-----------|------|-------|
| Detection / Alert Fire | T+0 | Monitoring |
| On-call acknowledge | T+15 min | Engineering on-call |
| Incident channel created | T+20 min | First responder |
| COO + CTO notified | T+30 min | On-call |
| Root cause identified | T+2 hrs | Engineering |
| User communication if >30 min | T+2 hrs | COO |
| Status page updated if applicable | T+30 min | Support Ops Agent |
| Resolution or detailed ETA | T+8 hrs | Engineering |
| Resolution confirmed | T+24 hrs target | Engineering |

### SEV3 — Business Hours Response

| Milestone | Time | Owner |
|-----------|------|-------|
| Detection / Alert Fire | T+0 | Monitoring |
| T2 engineer acknowledges | T+4 hrs (business) | T2 on-call |
| Initial assessment | T+8 hrs | T2 |
| Status page updated if >2 hrs | T+8 hrs | Support Ops Agent |
| Resolution | T+72 hrs target | T2 |
| Post-incident review | If SEV2+ criteria met | COO + CQO |

---

## 3. Escalation Path

### Primary On-Call Rotation

| Role | SEV1 | SEV2 | SEV3 |
|------|------|------|------|
| **Primary On-call** | Engineer (rotated weekly) | Engineer (rotated weekly) | T2 (business hours) |
| **Escalation 1** | Engineering Lead | Engineering Lead | T2 Lead |
| **Escalation 2** | CTO | CTO (SEV2 only if no progress in 2 hrs) | None |
| **Escalation 3** | CEO (T+30 min if no progress) | None | None |

### 3AM Wakeup Rules

**Who gets woken up for what:**

| Situation | Who Gets Called |
|-----------|----------------|
| SEV1 — any | CTO + Engineering Lead + COO |
| SEV1 — suspected breach | CTO + CQO + CEO |
| SEV1 — financial/billing | CTO + COO |
| SEV2 — no acknowledge in 30 min | CTO |
| SEV2 — no progress in 2 hrs | CTO |
| SEV2 — billing affected | COO |
| SEV3 — none | No 3am calls |

**On-call Tool:** PagerDuty with escalation policy:
- Page → 5 min silent → escalate to primary
- No acknowledge → 10 min → escalate to lead
- No acknowledge → 15 min → CTO
- No acknowledge → 30 min → CEO

---

## 4. Incident Roles

| Role | Responsibilities | Who |
|------|-----------------|-----|
| **Incident Commander (IC)** | Owns the incident end-to-end; drives resolution; coordinates responders; makes calls | Most senior engineer engaged |
| **Communications Lead** | Manages external communication; status page; user emails; press inquiries | COO (or Support Ops Agent) |
| **Technical Lead** | Drives root cause analysis; assigns fixes; validates resolution | Engineering Lead or Senior Engineer |
| **Scribe** | Documents timeline, decisions, actions in incident channel | First responder or designated agent |

**IC Transfer Protocol:**
- IC can hand off to more appropriate responder if incident scope changes
- Document the transfer explicitly in the incident channel: "Transferring IC to [name] at [time]"
- Old IC remains available for context

---

## 5. Communication Templates

### Status Page — Initial Update (SEV1/2)

```
[INC-YYYY-MM-DD-NNN] — [Service Name] Degradation

Status: [Investigating / Identified / Monitoring]
Impact: [Brief description of what's broken for users]
Affected: [% of users or specific tier]
Started: [ISO timestamp]
ETA: [If known — e.g., "We expect to have an update in 30 minutes"]

What we're doing: [1-2 sentences on investigation status]
Next update: [Time]

— Nestra Operations Team
```

### User Email — SEV1 (All users affected)

```
Subject: [URGENT] Nestra Service Outage — [Time]

Dear Nestra Home+ User,

We're experiencing an outage affecting [service]. Our team is actively working to restore service.

What this means for you:
• [Affected feature 1]
• [Affected feature 2]
• Your hub continues to run locally — voice control and local automations are NOT affected

We apologize for the disruption. We'll update you every 30 minutes until this is resolved.

Current status: status.nestra.io
Start time: [ISO timestamp]
Expected resolution: [ETA or "We don't have an ETA yet"]

Thank you for your patience,
The Nestra Operations Team
```

### User Email — SEV2 (Partial impact)

```
Subject: Nestra Performance Issue — [Service Name]

Dear Nestra User,

We're currently experiencing [brief description] affecting [subset of users / specific feature].

Impact: [What is not working]
Affected users: [Which tier or region]
Started: [ISO timestamp]

Your hub continues to run locally. [Any workaround available]

We expect this to be resolved by [ETA].

Current status: status.nestra.io

Thank you for your patience,
The Nestra Operations Team
```

### Community Forum Post (during active incident)

```
[MOD POST] — Known Issue: [Brief Title]

Hey everyone — we're aware of [brief description] affecting [who].

What's working: [list]
What's broken: [list]

Our team is on it. We'll update this thread every 30 minutes.

Timeline:
• [Time] — Investigating
• [Time] — Identified cause
• [Time] — Deploying fix
• [Time] — Resolved

Apologies for the disruption. — @nestra-ops
```

### Resolution Announcement

```
Subject: [RESOLVED] Nestra Service Restoration — [Service Name]

Dear Nestra User,

[Service] has been restored as of [ISO timestamp].

What was the issue: [1-2 sentence root cause — no gory details]
What we did: [High-level fix]
What we're doing to prevent this: [Prevention step]

If you continue to experience issues, please [contact support / restart your hub].

We apologize for the outage and appreciate your patience.

— The Nestra Operations Team
```

---

## 6. Post-Incident Review (PIR) Process

### When Required

| Severity | PIR Required | CEO Present |
|----------|--------------|-------------|
| SEV1 | Yes — mandatory | Yes |
| SEV2 | Yes — if >4 hrs or >500 users affected | COO + CTO |
| SEV3 | Optional — only if pattern detected | Not required |
| SEV4 | No | No |

### PIR Timeline

- **Draft PIR** due within 48 hours of resolution
- **PIR review meeting** within 5 business days
- **Action items** assigned and tracked in memory store
- **PIR published** to internal wiki within 7 days

### PIR Template

```
# Post-Incident Review — INC-[NUMBER]

**Incident:** [Title]
**Date:** [ISO]
**Duration:** [Start] → [End] = [X hrs Y min]
**Severity:** SEV[1-4]
**Status:** [Draft / Reviewed / Closed]

## Summary
[2-3 sentence executive summary — what happened, impact, resolution]

## Timeline
| Time | Event |
|------|-------|
| HH:MM | Alert fired |
| HH:MM | On-call acknowledged |
| HH:MM | IC assigned |
| HH:MM | Root cause identified |
| HH:MM | Fix deployed |
| HH:MM | Service restored |

## Impact
- Users affected: [number / %]
- Revenue impact: [if applicable]
- Data loss: [yes/no]
- Security implication: [yes/no]

## Root Cause
[Technical root cause — the "why" behind the failure]

## Contributing Factors
[What made this worse or harder to detect]

## Resolution
[What was done to restore service]

## Action Items

| Action | Owner | Due Date | Status |
|--------|-------|----------|--------|
| [Action 1] | [Name] | [Date] | [Open/Done] |
| [Action 2] | [Name] | [Date] | [Open/Done] |

## Lessons Learned
**What went well:**
- [Point 1]

**What could be improved:**
- [Point 1]

**What we'll do differently:**
- [Point 1]
```

---

## 7. Incident Detection & Monitoring

### Primary Alert Sources

| System | Monitors | Alert Threshold |
|--------|----------|----------------|
| Datadog | API latency, error rate, database health, cloud sync | >1% error rate for 5 min → SEV2 alert |
| PagerDuty | On-call routing, escalation, acknowledge | Auto-escalate if no ACK in 5/10/15 min |
| AWS/GCP Health | Region-level outages | Any region down → SEV1 |
| Hub Telemetry | % hubs offline, hub-to-cloud latency | >10% hubs offline → SEV2 |
| Stripe Dashboard | Payment failures, subscription errors | >5% payment failure rate → SEV2 |

### On-Call Schedule

- Primary on-call: Rotated weekly (Sunday midnight UTC)
- Secondary on-call: Engineering Lead (always reachable)
- Escalation: CTO (always reachable for SEV1)
- Current schedule: PagerDuty `nestra-oncall` schedule

---

## 8. Status Page Management

**Status Page URL:** status.nestra.io  
**Managed By:** Support Ops Agent (nestra-support-ops)  
**Provider:** Statuspage (Atlassian) or equivalent

### Status Page Components

| Component | Status Logic |
|-----------|-------------|
| **Nestra Cloud Sync** | UP if >99% of sync requests succeeding |
| **Nestra Hub OTA** | UP if >99% of OTA pushes delivering |
| **Mobile App (iOS)** | UP if app error rate <1% |
| **Mobile App (Android)** | UP if app error rate <1% |
| **Matter Bridge** | UP if bridge device connectivity >95% |
| **Auth Service** | UP if login success rate >99% |
| **Billing (Stripe)** | UP if payment processing >99% |

### Incident Post Timing

| Incident Age | Update Required |
|-------------|----------------|
| 0 min | Initial post (Investigating) |
| 30 min | Update or resolution |
| 60 min | Update if not resolved |
| Every 30 min | Subsequent updates until resolved |
| Resolution | Final "Resolved" post |

