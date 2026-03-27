# KPIS.md — JARVIS Home OS Operational KPIs & Dashboards

**Version:** 0.1.0  
**Owner:** COO (jarvis-coo)  
**BizOps Agent:** jarvis-bizops  
**Review Cadence:** Weekly executive review, monthly board review  
**Effective Date:** March 27, 2026  

---

## 1. Infrastructure KPIs

### Core Platform Health

| KPI | Definition | Target | Alert Threshold | Owner | Source |
|-----|-----------|--------|-----------------|-------|--------|
| **API Uptime** | % of time JARVIS cloud APIs are available | ≥ 99.9% | < 99.5% → SEV2 | CTO | Datadog synthetic monitoring |
| **API Latency P50** | Median API response time | < 100ms | > 250ms → SEV3 | CTO | Datadog APM |
| **API Latency P99** | 99th percentile API response time | < 500ms | > 1s → SEV3 | CTO | Datadog APM |
| **Error Rate** | % of API requests returning 4xx/5xx | < 0.1% | > 1% → SEV2 | CTO | Datadog APM |
| **Cloud Sync Success Rate** | % of sync operations completing successfully | ≥ 99.5% | < 99% → SEV2 | CTO | Custom telemetry |
| **Hub OTA Success Rate** | % of hub firmware updates delivering successfully | ≥ 98% | < 95% → SEV3 | CTO | Hub telemetry |

### Hub & Device Health

| KPI | Definition | Target | Alert Threshold | Owner | Source |
|-----|-----------|--------|-----------------|-------|--------|
| **Hub Online Rate** | % of registered hubs with heartbeat in last 5 min | ≥ 99% | < 97% → SEV2 | CTO | Hub telemetry |
| **Hub Firmware Currency** | % of hubs on latest stable firmware | ≥ 90% within 30 days | < 75% → SEV3 | CTO | Hub telemetry |
| **Matter Device Connectivity** | % of paired Matter devices responding | ≥ 98% | < 95% → SEV3 | CTO | Hub telemetry |
| **Local Voice Latency** | Time from voice command to local execution | < 200ms | > 500ms → SEV3 | CTO | Hub telemetry |
| **Hub Restart Rate** | Avg hub reboots per week per household | < 1/week | > 3/week → SEV3 | CTO | Hub telemetry |

### Security / Abuse

| KPI | Definition | Target | Alert Threshold | Owner | Source |
|-----|-----------|--------|-----------------|-------|--------|
| **Failed Auth Rate** | % of auth attempts failing | < 1% | > 5% → SEV2 | CTO | Auth service logs |
| **Account Lockout Rate** | Lockouts per 1000 users | < 5 | > 20 → SEV3 | CTO | Auth service logs |
| **Security Scan Findings** | Critical/high vulnerabilities found | 0 critical; < 5 high | Any critical → SEV1 | CQO | Security scanner |

---

## 2. Support KPIs

### Volume & Response

| KPI | Definition | Target | Alert Threshold | Owner | Source |
|-----|-----------|--------|-----------------|-------|--------|
| **Ticket Volume (Weekly)** | Total new tickets received per week | Baseline: TBD post-launch | > 2x baseline → investigate | Support Ops | Zendesk |
| **Ticket Backlog** | % of open tickets older than SLA | < 5% | > 10% → escalate | Support Ops | Zendesk |
| **T1 First Response Time (Avg)** | Avg time to first agent response | < 4 hrs | > 6 hrs → escalate | Support Ops | Zendesk |
| **T2 First Response Time (Avg)** | Avg time to T2 engineer response | < 2 hrs | > 4 hrs → escalate | Eng Lead | Zendesk |
| **Resolution Time (Median)** | Median time from ticket open to resolved | < 24 hrs | > 48 hrs → escalate | Support Ops | Zendesk |

### Quality

| KPI | Definition | Target | Alert Threshold | Owner | Source |
|-----|-----------|--------|-----------------|-------|--------|
| **CSAT Score (1-5)** | Avg customer satisfaction on post-resolution survey | ≥ 4.2 | < 3.8 → review | Support Ops | Zendesk |
| **First Contact Resolution (FCR)** | % of tickets resolved without escalation | ≥ 60% | < 50% → review | Support Ops | Zendesk |
| **Escalation Rate** | % of T1 tickets escalated to T2 | < 20% | > 30% → review | Support Ops | Zendesk |
| **Ticket Reopen Rate** | % of tickets reopened after resolution | < 5% | > 10% → review | Support Ops | Zendesk |

### Community

| KPI | Definition | Target | Alert Threshold | Owner | Source |
|-----|-----------|--------|-----------------|-------|--------|
| **Forum Posts (Monthly)** | New community posts per month | Growing MoM | Flat/declining → review | Community Agent | Forum admin |
| **Forum Response Time** | Avg time to first community response | < 24 hrs | > 48 hrs → T1 assist | Community Agent | Forum admin |
| **Forum Resolution Rate** | % of community questions answered | ≥ 80% | < 60% → T1 assist | Community Agent | Forum admin |

---

## 3. Business KPIs

### Revenue & Growth

| KPI | Definition | Target | Alert Threshold | Owner | Source |
|-----|-----------|--------|-----------------|-------|--------|
| **Monthly Recurring Revenue (MRR)** | Total subscription revenue per month | Growing MoM | Flat/declining MoM → CEO alert | COO | Stripe Dashboard |
| **Annual Recurring Revenue (ARR)** | MRR × 12 | Growing QoQ | Flat → CEO alert | COO | Stripe Dashboard |
| **MRR Growth Rate** | Month-over-month % increase | ≥ 10% MoM | < 5% → review | COO | Stripe Dashboard |
| **Average Revenue Per User (ARPU)** | MRR / # paying users | Growing YoY | Declining → price analysis | COO | Stripe + internal |
| **Logo Churn Rate** | % of paying customers who cancel | < 5%/month | > 8% → CEO alert | COO | Stripe Dashboard |
| **Revenue Churn Rate** | % of MRR lost to cancellations | < 3%/month | > 5% → CEO alert | COO | Stripe Dashboard |

### Subscriptions

| KPI | Definition | Target | Alert Threshold | Owner | Source |
|-----|-----------|--------|-----------------|-------|--------|
| **Free → Home+ Conversion Rate** | % of free users who upgrade to Home+ | ≥ 3% within 30 days | < 1% → product review | CRO | Internal analytics |
| **Home+ Monthly Churn** | % of Home+ subscribers canceling each month | < 5% | > 7% → churn analysis | COO | Stripe |
| **Home+ Annual Churn** | % of annual subscribers canceling early | < 10% | > 15% → refund analysis | COO | Stripe |
| **Enterprise Pipeline** | # of active white-label deal conversations | Growing | Stalled → CRO review | CRO | CRM |
| **Enterprise ACV (Annual Contract Value)** | Avg annual contract value per enterprise deal | > $50K | < $25K → margin review | CRO | CRM |

### Customer Acquisition

| KPI | Definition | Target | Alert Threshold | Owner | Source |
|-----|-----------|--------|-----------------|-------|--------|
| **Customer Acquisition Cost (CAC)** | Total sales & marketing spend / # new customers | Decreasing or stable | > 20% increase → review | CRO | Marketing analytics |
| **Blended CAC** | Combined Home+ + Enterprise | Benchmark: TBD | Within 20% of LTV | CRO | Marketing analytics |
| **LTV:CAC Ratio** | Lifetime value / customer acquisition cost | ≥ 3:1 | < 2:1 → unsustainable | COO | Internal |
| **Payback Period** | Months to recover CAC | < 12 months | > 18 months → CAC review | COO | Internal |

---

## 4. Product KPIs

### Activation & Engagement

| KPI | Definition | Target | Alert Threshold | Owner | Source |
|-----|-----------|--------|-----------------|-------|--------|
| **Weekly Active Users (WAU)** | Unique users with ≥1 interaction per week | Growing MoM | Flat → product review | CPO | Analytics |
| **Monthly Active Users (MAU)** | Unique users with ≥1 interaction per month | Growing MoM | Flat → product review | CPO | Analytics |
| **WAU:MAU Ratio (Stickiness)** | WAU / MAU | ≥ 40% | < 30% → engagement review | CPO | Analytics |
| **Activation Rate** | % of signups who complete core setup within 7 days | ≥ 50% | < 30% → onboarding review | CPO | Analytics |
| **Hub Setup Completion Rate** | % of users who complete hub setup after starting | ≥ 70% | < 50% → setup flow review | CPO | Analytics |
| **First Skill Created** | % of users who create first automation | ≥ 40% within 30 days | < 25% → skills onboarding | CPO | Analytics |

### Feature Adoption

| KPI | Definition | Target | Alert Threshold | Owner | Source |
|-----|-----------|--------|-----------------|-------|--------|
| **Voice Command Usage** | Avg voice commands per household per day | ≥ 10/day (active users) | Declining → voice UX review | CPO | Analytics |
| **Cloud Sync Adoption** | % of Home+ users who enable cloud sync | ≥ 80% | < 60% → value prop review | CPO | Analytics |
| **Matter Device Pairing** | Avg Matter devices paired per household | ≥ 5 devices | < 3 → device onboarding | CPO | Analytics |
| **Skill Marketplace Visits** | % of users visiting skill marketplace | ≥ 30% monthly | < 15% → marketplace discovery | CPO | Analytics |
| **Parental Controls Usage** | % of households with children using parental controls | ≥ 70% of households with kids | < 50% → parental controls promotion | CPO | Analytics |

### NPS & Sentiment

| KPI | Definition | Target | Alert Threshold | Owner | Source |
|-----|-----------|--------|-----------------|-------|--------|
| **Net Promoter Score (NPS)** | 0-10 likelihood to recommend | ≥ 40 | < 25 → product crisis | CPO | Delighted/Typeform |
| **App Store Rating** | Avg of iOS + Android app store rating | ≥ 4.3 | < 4.0 → review | CPO | App stores |
| **Reviews per Month** | New app store reviews | Growing | Declining → review | CPO | App stores |
| **Social Sentiment Score** | % positive mentions / total | ≥ 80% | < 70% → comms review | CRO | Mention |

---

## 5. Dashboard Overview

### Executive Dashboard (Weekly Review)

**Who:** CEO, COO, CPO, CTO, CRO  
**When:** Every Monday, 9am PT  
**Tool:** Notion / Google Sheets / Looker

| Section | Key Metrics |
|---------|------------|
| **Revenue** | MRR, MRR Growth %, Logo Churn, New MRR |
| **Acquisition** | New signups, Free→Home+ conversions, CAC |
| **Engagement** | WAU, WAU:MAU, Activation Rate |
| **Support** | Ticket volume, CSAT, Resolution time |
| **Infrastructure** | API uptime, Error rate, Hub online rate |
| **NPS** | Current NPS, Trend, Recent verbatims |

### Board Dashboard (Monthly)

**Who:** CEO + Board members  
**When:** First Monday of month  
**Format:** PDF / slides

| Section | Key Metrics |
|---------|------------|
| **Financials** | MRR, ARR, Churn, CAC, LTV:CAC, ARPU |
| **Growth** | WAU growth %, MAU growth %, Conversion rate |
| **Retention** | Churn rate, NPS, App store rating |
| **Pipeline** | Enterprise deals in pipeline, ACV, Stage |
| **Operational Health** | Uptime SLA compliance, CSAT, Escalation rate |
| **Product** | Feature adoption, Key milestones |

### Real-Time Operations Dashboard

**Who:** On-call engineering, Support Ops Agent  
**When:** Always visible (monitoring)  
**Tool:** Datadog / Grafana

| Section | Key Metrics |
|---------|------------|
| **API Health** | Error rate, Latency P50/P99, Uptime |
| **Hub Fleet** | Online %, Firmware currency, Restart rate |
| **Support Queue** | Open tickets by priority, Avg wait time, CSAT |
| **Incidents** | Active incidents, Recent resolved |
| **Billing** | Payment failure rate, Failed charges, Disputes |

---

## 6. KPI Review Cadence

| Review | Frequency | Owner | Participants | Output |
|--------|-----------|-------|-------------|--------|
| **Metric Baseline** | Pre-launch (4 weeks) | All C-suite | All | Establish baselines |
| **Weekly Pulse** | Weekly (Monday) | COO | All C-suite | Status update, flag issues |
| **Monthly Review** | Monthly | COO | All C-suite + leads | Trend analysis, decisions |
| **Quarterly Business Review** | Quarterly | CEO | All C-suite | Strategic adjustments, board report |
| **Annual Planning** | Annual | CEO | All C-suite | Next year targets, OKRs |

---

## 7. Alerting & Escalation

### Alert Tiers

| Tier | Criteria | Action | Who Notified |
|------|----------|--------|-------------|
| **P0 — Critical** | API down, SEV1, security breach | Page on-call → PagerDuty | CTO, COO, CEO |
| **P1 — High** | Error rate > 1%, latency > 1s, churn spike | Slack alert + PagerDuty | CTO, Support Ops |
| **P2 — Medium** | Ticket backlog > 10%, CSAT < 3.8 | Slack alert | Support Ops, COO |
| **P3 — Low** | KB article flagged, single complaint trend | Weekly review | T1 Lead |

### Escalation Criteria

| Metric | Warning | Critical | Action |
|--------|---------|----------|--------|
| API Uptime (monthly) | < 99.5% | < 99.0% | PIR required |
| CSAT | < 4.0 | < 3.5 | Support review + escalation |
| Churn (monthly) | > 6% | > 10% | CEO review |
| Activation Rate | < 40% | < 25% | Product redesign review |
| Ticket Backlog | > 10% | > 20% | Support surge activated |

---

## 8. KPI Ownership Matrix

| Metric | Owner | Agent | Data Source | Dashboard |
|--------|-------|-------|-------------|-----------|
| API Uptime | CTO | jarvis-cto | Datadog | Ops Dashboard |
| Error Rate | CTO | jarvis-cto | Datadog | Ops Dashboard |
| Hub Online Rate | CTO | jarvis-cto | Hub telemetry | Ops Dashboard |
| Ticket Volume | COO | jarvis-support-ops | Zendesk | Support Dashboard |
| CSAT | COO | jarvis-support-ops | Zendesk | Support Dashboard |
| MRR | COO | jarvis-bizops | Stripe | Finance Dashboard |
| Churn Rate | COO | jarvis-bizops | Stripe | Finance Dashboard |
| CAC | CRO | jarvis-cro | Marketing analytics | Marketing Dashboard |
| WAU | CPO | jarvis-cpo | Analytics | Product Dashboard |
| Activation Rate | CPO | jarvis-cpo | Analytics | Product Dashboard |
| NPS | CPO | jarvis-cpo | Delighted | Product Dashboard |
| App Store Rating | CPO | jarvis-cpo | App stores | Product Dashboard |
| Security Findings | CQO | jarvis-cqo | Security scanner | Security Dashboard |
| Matter Certification | CQO | jarvis-cqo | CSA portal | Compliance Dashboard |
