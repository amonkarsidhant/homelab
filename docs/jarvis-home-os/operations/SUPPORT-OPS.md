# SUPPORT-OPS.md — JARVIS Home OS Support Operations Model

**Version:** 0.1.0  
**Owner:** COO (jarvis-coo)  
**Support Agent:** jarvis-support-ops  
**Effective Date:** March 27, 2026  

---

## 1. Support Tier Structure

### Tier 1 (T1) — First Response & Resolution

| Attribute | Detail |
|-----------|--------|
| **Role** | First-line support; mobile app in-app chat; community forum moderation |
| **Response SLA** | First response within 4 business hours |
| **Resolution SLA** | Resolve within 24 business hours (or escalate) |
| **Ownership** | Support Ops Agent (jarvis-support-ops) + human moderators |
| **Tools** | Intercom (in-app chat), Zendesk (tickets), community forum (forum.jarvis.io) |

**T1 Handles:**
- "JARVIS is not responding" — basic troubleshooting (restart app, check hub, check internet)
- Billing questions — plan upgrades, payment failures, subscription cancellations
- Onboarding questions — how to set up hub, pair first device, create account
- "How do I..." questions — knowledge base article routing
- Community forum first-line moderation (spam, tos violations)
- Feature requests — logged, not actioned by T1

**T1 Does NOT Handle:**
- Technical escalations requiring engineering access
- Security vulnerability reports (→ CQO directly)
- Legal / compliance requests (→ COO)
- Refund requests >$500 or >2 prior refunds (→ T2)

---

### Tier 2 (T2) — Technical Support & Engineering

| Attribute | Detail |
|-----------|--------|
| **Role** | Technical investigation; debugging; hotfix deployment; configuration issues |
| **Response SLA** | First response within 2 business hours |
| **Resolution SLA** | Resolve within 48 business hours (or escalate to T3) |
| **Ownership** | Engineering on-call; Support Ops Agent + human L2 engineers |
| **Tools** | PagerDuty, Datadog, AWS/GCP console access (read-only), log aggregation |

**T2 Handles:**
- JARVIS hub not booting (Raspberry Pi image issues)
- Matter device pairing failures (debugging device compatibility)
- Cloud sync failures (account-level debugging)
- Performance degradation (>30% latency increase detected)
- Mobile app crashes requiring backend investigation
- White-label brand partner technical issues (→ dedicated Slack channel)
- Billing system errors (Stripe dashboard access required)

**T2 Does NOT Handle:**
- Architectural changes or new feature development
- Security incidents (→ CQO)
- refunds, legal, compliance escalations (→ COO)

---

### Tier 3 (T3) — Senior Engineering & Architecture

| Attribute | Detail |
|-----------|--------|
| **Role** | Root cause analysis; architectural fixes; major incidents; 0-day responses |
| **Response SLA** | Engaged within 1 hour (SEV1/2); async for SEV3 |
| **Resolution SLA** | Variable — based on incident severity |
| **Ownership** | Senior engineers; CTO on-call for SEV1 |
| **Tools** | Full infrastructure access; AWS/GCP console; GitHub; PagerDuty |

**T3 Handles:**
- SEV1 incidents (full outage, data loss, breach)
- Root cause of recurring T2 escalations
- Infrastructure-level issues (database, message queue, cloud provider)
- Matter protocol certification failures
- Security incidents requiring quarantine
- Agent runtime failures (JARVIS brain stops reasoning)
- Customer data access requests (GDPR/CCPA — COO must authorize first)

---

## 2. Ticket SLA Targets

| Tier | Priority | First Response | Resolution Target | Max Age Before Escalation |
|------|----------|----------------|-------------------|--------------------------|
| T1 | Urgent (user can't use product) | 4 business hours | 24 business hours | 12 business hours |
| T1 | Normal | 8 business hours | 48 business hours | 24 business hours |
| T1 | Low (questions, feature requests) | 24 business hours | 5 business days | 72 business hours |
| T2 | SEV2 (major outage) | 2 business hours | 8 hours | Immediate escalation |
| T2 | SEV3 (minor outage) | 4 business hours | 72 hours | 24 hours |
| T3 | SEV1 (full outage) | 1 hour | 4 hours | Immediate — CEO notified |

### SLA Breach Handling
- **T1 SLA breach (>50% of tickets over SLA):** Support Ops Agent escalates to COO; temporary L2 assistance activated
- **T2 SLA breach:** On-call engineering lead notified; CTO reviews within 4 hours
- **SLA breaches are reviewed weekly** in the operational review meeting

---

## 3. Community Forum vs Official Support

| Channel | Owner | Scope | SLA |
|---------|-------|-------|-----|
| **forum.jarvis.io** | T1 + Community Agent | How-to questions, feature discussions, tips & tricks, community troubleshooting | Moderation within 4 hrs; answers not SLA-bound |
| **support@jarvis.io** | T1 → T2 | Billing issues, account problems, technical bugs requiring agent logs | 4 hr first response (business hours) |
| **In-app chat** | T1 (Intercom) | Real-time troubleshooting during active user sessions | Immediate triage; 4 hr response |
| **Enterprise portal** (white-label brands) | T2 + CRO relationship owner | Brand-specific technical issues, OEM integration questions | 2 hr first response; 24 hr resolution |
| **Security reports** | CQO directly | security@jarvis.io — do NOT route through normal support | No SLA — CQO responds within 24 hrs |

### Community Forum Triage Rules
- **Spam / promotional:** T1 deletes within 1 hour
- **Bug reports:** T1 logs in ticket system; links to bug tracker
- **Feature requests:** T1 acknowledges; posts in #feature-requests channel; no commitment
- **Legal / compliance:** T1 does NOT respond; escalates to COO immediately
- **Privacy complaints:** T1 does NOT respond; escalates to CQO immediately

---

## 4. Self-Service Knowledge Base Categories

**Knowledge Base URL:** docs.jarvis.io / help.jarvis.io

| Category | Contents | Managed By |
|----------|----------|------------|
| **Getting Started** | Hub setup guide, app installation, first device pairing, account creation | T1 + CPO |
| **Account & Billing** | Plan comparison, upgrade/downgrade, cancel subscription, payment methods, invoices | T1 |
| **Troubleshooting** | "JARVIS is not responding" flow, hub LED codes, app crash solutions, network requirements | T2 |
| **Matter Devices** | Compatible device list, pairing guides, Matter protocol FAQ, device-specific tips | T2 |
| **Skills & Automations** | How to create automations, skill marketplace, skill permissions, voice commands | T1 + CPO |
| **Privacy & Security** | Data collected, local vs cloud mode, parental controls, data export, account deletion | T1 + CQO |
| **White-Label / Brands** | OEM integration guide, branding requirements, per-device pricing FAQ | CRO + T2 |
| **Developer API** | API reference, webhook docs, self-hosting guide, SDK | T2 + CTO |

**KB Article Health Metrics:**
- Articles with <50% helpful rating → flagged for T2 review
- Articles with >10 searches/mo but low success rate → priority rewrite
- Articles older than 6 months → quarterly review cycle

---

## 5. Mobile App In-App Support (When JARVIS is Broken)

### Scenario: User Opens App and JARVIS is Unresponsive

**If cloud sync is down (SEV1/2):**

1. **App shows degraded state banner:**
   > "JARVIS is experiencing issues. Your hub is still running locally — [list what works offline]. Cloud features (remote access, cloud sync) are temporarily unavailable. [Track status →]"

2. **Tapping the banner** → links to status.jarvis.io with live incident page

3. **Core local features remain active:**
   - Voice control of paired Matter devices (local LAN)
   - Hub-local automations
   - App → hub communication (same network)
   - Manual device control

4. **What is NOT available when cloud is down:**
   - Remote access (outside home network)
   - Cloud sync / cross-device state
   - Skills that require cloud inference
   - Account management via app

**If the hub itself is down (hub unreachable):**

1. **App shows full-screen error state:**
   > "Hub Unreachable"
   > "JARVIS hub at [address] is not responding. Please check: Is the hub powered on? Is your phone on the same network?"
   > [Show troubleshooting steps 1-2-3]
   > [Contact Support] [Retry]

2. **Retry button:** Re-pings hub every 10 seconds; auto-dismisses if hub returns

3. **Contact Support:** Opens T1 ticket pre-filled with:
   - Hub UUID (anonymous)
   - Last known state
   - App version
   - Time since hub unreachable

**If this is a known incident (status page active):**

1. **App shows yellow banner at top:**
   > "Known Issue — We're aware of [brief description]. ETA: [time]. [Learn More]"

2. **No ticket needed** — banner links to status page

---

## 6. Support Ticket Workflow

```
[User submits ticket — email, in-app, forum, phone]
        ↓
   T1 Automated Acknowledge (bot, <5 min)
        ↓
   T1 Human Triage:
   ├── Can resolve? → Reply with solution + KB link → Close (CSAT survey)
   ├── Need T2? → Assign T2 tag → Forward → T2 engages
   ├── Need T3? → Escalate via PagerDuty → T3 on-call
   ├── Need CQO? → Forward security@ → CQO direct
   └── Need COO? → Legal/compliance/financial >$500 → COO ticket
        ↓
   Resolution + CSAT survey sent
        ↓
   [If CSAT < 3/5 or user replies] → T1 re-engage or escalate
```

---

## 7. Support Quality Metrics

| Metric | Target | Owner | Review Frequency |
|--------|--------|-------|-----------------|
| Ticket CSAT (1-5) | ≥ 4.2 | Support Ops Agent | Weekly |
| First Contact Resolution (FCR) | ≥ 60% | T1 | Weekly |
| T1 Avg Response Time | < 4 hrs | Support Ops Agent | Weekly |
| T2 Avg Response Time | < 2 hrs | Engineering Lead | Weekly |
| Ticket Backlog (open >5 days) | < 5% | Support Ops Agent | Weekly |
| Escalation Rate (T1→T2) | < 20% | Support Ops Agent | Weekly |
| Knowledge Base Helpfulness Rate | ≥ 80% | T1 + T2 | Monthly |
