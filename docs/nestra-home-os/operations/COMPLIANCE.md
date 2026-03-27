# COMPLIANCE.md — Nestra Home OS Compliance & Regulatory Requirements

**Version:** 0.1.0  
**Owner:** COO (nestra-coo) + CQO (nestra-cqo) co-owned  
**Compliance Agent:** nestra-compliance  
**Effective Date:** March 27, 2026  

---

## 1. GDPR Obligations

**Legal Basis:** GDPR applies to Nestra if we have users in the EU/EEA or users who are EU/EEA residents, regardless of where Nestra is hosted. We operate globally, so GDPR applies as a baseline.

### Data We Collect (GDPR Article 13/14 Disclosure)

| Data Category | Examples | Legal Basis | Retention |
|--------------|----------|------------|-----------|
| Account identity | Name, email, phone number | Contract (account creation) | Until account deletion |
| Household profile | Members, roles, preferences | Consent | Until account deletion |
| Voice commands | Audio transcripts | Consent (opt-in for cloud assist) | 30 days or until user deletes |
| Device state | Which devices, when, how used | Contract (service delivery) | 90 days aggregate; 30 days raw |
| Location | Home address (for local processing) | Consent | Until account deletion |
| Billing | Stripe payment info, invoices | Legal obligation (tax) | 7 years per tax law |
| Hub telemetry | Uptime, error logs, crash reports | Legitimate interest (ops) | 90 days |

### Right to Erasure (Article 17)

Users must be able to delete their account and all associated data. Implementation:

1. **In-app deletion flow:** Settings → Privacy → Delete Account → Confirmation email → 7-day grace period
2. **What deletion removes:** All personal data, household members, voice transcripts, preferences
3. **What we retain:** Aggregated/anonymized telemetry (no individual identified), financial records (7-year tax obligation), legal holds on data required for pending disputes
4. **Deletion SLA:** Complete within 30 days of request
5. **Deletion confirmation:** Email sent to user upon completion

**Deletion Request Flow:**
```
User submits deletion request (in-app or privacy@nestra.io)
  → Support Ops Agent verifies identity (2-factor)
  → Legal hold check (any pending issues?)
    ├── Yes → pause deletion, notify user of delay (max 30 days additional)
    └── No → proceed
  → Data Deletion Agent triggers deletion pipeline
  → Confirmation email sent
  → Ticket closed
```

### Data Portability (Article 20)

Users can export all their data in machine-readable format.

1. **Export format:** JSON (primary), CSV (for tabular data like device history)
2. **Export includes:** Account profile, household members, device configurations, automation rules, voice command history (30-day window), billing history (user must request from Stripe directly)
3. **Delivery method:** Download link emailed within 24 hours (expires in 48 hours)
4. **Request SLA:** Fulfilled within 72 hours

### Consent Requirements

| Action | Consent Type | How Obtained | Withdrawable |
|--------|-------------|--------------|--------------|
| Account creation | Necessary | Checkbox (contract) | Via account deletion |
| Cloud sync (Home+) | Opt-in | In-app prompt during onboarding | Settings → toggle off |
| Voice assist (cloud) | Opt-in | In-app prompt before first use | Settings → toggle off |
| Analytics / crash reports | Opt-in | First launch prompt | Settings → toggle off |
| Marketing emails | Opt-in | Separate checkbox at signup | Every email has unsubscribe |
| Children under 16 | Parental consent | Parental consent flow | Via family management |

**Consent Records:** Stored with timestamp, version of privacy policy at time of consent, mechanism used to obtain consent.

### Data Protection Officer (DPO)

- Nestra Home OS is likely not required to appoint a DPO (we have <250 employees, no systematic large-scale processing of special categories)
- However, we designate a **Privacy Lead** (COO role) who serves as point of contact for GDPR matters
- External DPO consultation retained for any EU/EEA expansion

### Data Breach Notification (Articles 33/34)

| Scenario | Notification | Timeline |
|----------|-------------|----------|
| Breach affecting EU users | Supervisory authority (DPA) | 72 hours of becoming aware |
| Breach likely causing high risk to rights | Affected users | Without undue delay |
| Non-EU breach with EU personal data | Internal only | Assess if EU users affected |

### Sub-Processors (Article 28)

| Sub-Processor | Purpose | Data Shared | Agreement |
|---------------|---------|-------------|-----------|
| AWS/GCP | Cloud hosting | All data (user, household, telemetry) | DPA + SCCs |
| Stripe | Payment processing | Billing data only | Stripe SSA |
| Twilio | SMS notifications | Phone numbers, message content | DPA |
| Datadog | Monitoring/logging | Error logs, metrics (anonymized) | DPA |
| SendGrid | Transactional email | Email addresses, names | DPA |
| Statuspage | Incident communication | No personal data | DPA |

---

## 2. CCPA Obligations

**Legal Basis:** CCPA applies to Nestra if we have >$25M annual revenue OR we buy/sell/share personal data of >100,000 California consumers/households. We must comply from day one to enable growth.

### California Consumer Rights

| Right | How Exercised | Response Time |
|-------|--------------|---------------|
| **Right to Know** | Submit request (email/in-app) | 45 days |
| **Right to Delete** | Submit request → identity verification → deletion | 45 days |
| **Right to Opt-Out** | "Do Not Sell/Share My Personal Information" link in footer | Immediate (opt-out honored immediately) |
| **Right to Correct** | Account settings → correct inaccurate data | 45 days |
| **Right to Limit Use of Sensitive PI** | Settings → limit | Immediate |

### Privacy Notice Requirements

- Posted at: nestra.io/privacy
- Updated at least annually and within 30 days of material changes
- Includes: categories of PI collected, purposes, sharing practices (including for advertising if applicable)

### "Do Not Sell/Share" Implementation

If we ever use personal data for advertising or analytics sold to third parties:
- Global opt-out mechanism (GPC) supported
- "Do Not Sell/Share" link in website/app footer
- Do NOT sell personal data of users known to be under 16

### Non-Discrimination (CCPA Section 999.306)

- Cannot charge different prices for exercising CCPA rights
- Cannot provide different quality of service for exercising CCPA rights
- Exception: Price differences reflecting actual differences in value delivered

---

## 3. Matter Certification Requirements

**Standard:** Matter 1.x (Connectivity Standards Alliance)  
**Why it matters:** Matter certification is required to legally claim "Matter-compatible" and use the Matter logo on products.

### Certification Path

| Phase | What's Certified | Who Certifies | Cost |
|-------|-----------------|--------------|------|
| **Component certification** | Individual chips/modules (e.g., Wi-Fi radio) | CSA-approved test labs | ~$10-50K per component |
| **Product certification** | Full Nestra hub + app | CSA-approved test labs (UL, DEKRA, TÜV) | ~$30-100K per product SKU |
| **Family certification** | Related products under one declaration | CSA | ~$5-15K per additional SKU |

### What's Tested

| Test Category | What It Covers | Pass Criteria |
|--------------|--------------|--------------|
| **Matter Protocol** | Device pairing, commissioning, IP connectivity | 100% of Matter test suite |
| **Thread/BLE** | Low-power device commissioning | Specific test cases |
| **Audio/Video** | Voice assistant integration | Functional + performance |
| **Security** | Device attestation, secure boot, OTA updates | CSA security requirements |
| **Interoperability** | Works with Apple Home, Google Home, Amazon Alexa | 5-platform test matrix |
| **Functional** | All declared features work as specified | Product-specific test plan |

### Certification Timeline

1. **Pre-certification:** 4-8 weeks (internal testing, fixing)
2. **Test lab submission:** 2-4 weeks
3. **Lab testing:** 4-8 weeks
4. **CSA review:** 2-4 weeks
5. **Total:** ~12-24 weeks for first product certification

### Post-Certification Requirements

- Maintain certification for all sold products
- Report field issues to CSA within 30 days
- Apply for recertification when making hardware changes
- Use only CSA-approved test labs (list on CSA website)

### What Happens Without Certification

- Cannot use Matter logo or claim "Matter compatible"
- Competitors/compliance authorities can challenge claims
- Potential legal liability for false advertising

---

## 4. Financial / Billing Compliance

### Stripe Integration

**Requirements:**
- PCI DSS compliance (Stripe handles card data; we handle name, email, subscription state)
- Use Stripe's official SDKs only
- Never log or store card numbers, CVVs, or full card numbers
- Implement SCA (Strong Customer Authentication) for EU payments (Stripe handles automatically)

**Billing Rules:**
- Subscription renewals: Managed by Stripe Billing; we receive webhook events
- Failed payments: Retry schedule: Day 1, Day 3, Day 7, then suspend
- Refunds: Processed via Stripe dashboard; 30-day refund window for Home+ (discretionary for higher amounts)
- Disputes (chargebacks): T2 handles; flag to COO if >$200 or pattern detected

### Subscription Tiers (GDPR/CCPA Billing Considerations)

| Tier | Auto-renewal | Cancellation | Refund Policy |
|------|-------------|--------------|---------------|
| Free | N/A | N/A | N/A |
| Home+ ($9.99/mo) | Yes — monthly | Any time, effective end of period | 7-day money-back guarantee |
| Home+ Annual ($89/yr) | Yes — annually | Any time, prorated refund within 30 days | 30-day money-back guarantee |
| Enterprise | Per contract | Per contract terms | Per contract |

### Tax Compliance

- Collect and remit sales tax where required (US — economic nexus thresholds)
- VAT collection for EU/UK (VAT number verification via VIES)
- Track tax jurisdiction changes for subscription billing
- Issue invoices for all paid transactions (Stripe auto-generates)
- Retain financial records: 7 years (IRS / local tax authority requirement)

### Financial Reporting

- Monthly financial close: 5 business days after month end
- Annual audited financials required if >$200K revenue
- CFO/COO review of Stripe dashboard weekly

---

## 5. Children's Privacy (COPPA)

**Legal Basis:** COPPA applies if Nestra has actual knowledge of collecting personal information from children under 13. If we allow household accounts that include children, we must comply.

### Nestra Household Model (Complicates COPPA)

Nestra is a household product — multiple family members use one hub. This means:
- Parents create accounts
- Children may use the app or voice commands
- We may collect voice data from children

### Compliance Requirements

| Requirement | Implementation |
|-------------|----------------|
| **Verifiable Parental Consent (VPC)** | Required before collecting personal info from known children <13 |
| **Parental access** | Parents can review, delete, stop collection of child's data |
| **Data minimization** | Only collect what's necessary for participation |
| **No incentive** | Cannot use child's data to incentivize participation |
| **Policy posting** | Clear privacy policy in plain language |

### Implementation

**Household with Children:**
1. When creating household, user indicates if children <13 are present (optional, not required to disclose)
2. If child identified → parental consent flow triggered before child profile created
3. Child profiles are restricted — no cloud sync of voice commands, limited data retention
4. Parental dashboard shows all data associated with child profiles
5. Parents can delete child profiles at any time

**Age Gating:**
- App requires user to confirm they are 13+ to create account
- No personal data collected from confirmed child accounts
- Actual knowledge standard: If we learn a user is <13, we must delete data and close account within 30 days

### Parental Controls in Nestra

| Feature | What It Does |
|---------|-------------|
| **Child profiles** | Limited skills, no cloud voice assist, no social features |
| **Content filter** | Skill marketplace filter for child-appropriate only |
| **Screen time** | Hour limits per day, bedtime lock |
| **Activity report** | Weekly email to parent showing child's Nestra usage |
| **Voice command log** | Parents can review child's recent voice commands |
| **Delete child data** | One-click deletion of all child's data |

### UK Children's Code (Age Appropriate Design)

Even if COPPA doesn't apply (non-US users), UK Children's Code (Age Appropriate Design) applies to services likely accessed by children in the UK:
- High default privacy settings for all users
- No nudge design to undermine parental controls
- No profiling of children
- Data minimization by default

---

## 6. Additional Compliance Areas

### SOC 2 Type II (Future — Enterprise Tier)

Required for enterprise/brand partnerships (IKEA, Wayfair, etc.)

**When to pursue:** Before first enterprise deal signature

**Trust principles:**
- Security (required)
- Availability (for cloud services)
- Confidentiality (for all tiers)

**Timeline:** 6-12 months to achieve certification  
**Cost:** $20-100K depending on readiness

### Accessibility (ADA / Section 508)

Nestra mobile app must be accessible:
- WCAG 2.1 AA compliance
- Voice control as alternative to touch
- Screen reader support
- Large text / high contrast options

**Who reviews:** CQO runs accessibility audit before each major release

### Export Controls

If shipping Nestra internationally:
- Encryption: Ensure crypto exports comply with US EAR (Export Administration Regulations)
- Embargoed countries: Do not offer Nestra in US embargoed jurisdictions
- Sanctions screening: Stripe and App Store handles distribution compliance

---

## 7. Compliance Calendar

| Month | Activity |
|-------|----------|
| January | Annual GDPR privacy policy review |
| March | SOC 2 readiness assessment |
| June | COPPA/Children's Code compliance audit |
| September | CCPA audit and consumer request review |
| December | Year-end data retention purge |
| Ongoing | Matter certification maintenance (annual review) |
| Ongoing | PCI DSS compliance monitoring (Stripe SAQ-A self-assessment) |

---

## 8. Compliance Ownership

| Requirement | Owner | Agent |
|-------------|-------|-------|
| GDPR compliance | COO | nestra-compliance |
| CCPA compliance | COO | nestra-compliance |
| COPPA compliance | CQO | nestra-compliance-audit |
| Matter certification | CTO | nestra-cqo |
| Financial/billing compliance | COO | nestra-compliance |
| Accessibility compliance | CQO | nestra-qa |
| SOC 2 | COO + CTO | Both + external auditor |
