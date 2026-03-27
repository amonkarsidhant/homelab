# Nestra Home OS — Feature Matrix v0.1

**Version:** 0.1  
**Author:** CPO (Chief Product Officer)  
**Date:** March 27, 2026  
**Methodology:** RICE scoring (Reach × Impact × Confidence ÷ Effort)  

---

## RICE Scoring Guide

| Factor | Definition | Scale |
|--------|------------|-------|
| **Reach** | How many households (out of 10,000 v0.1 TAM) will benefit in 3 months | 1–10 (10 = 10,000 households) |
| **Impact** | How much does this move the needle on core metrics (activation, WAU, NPS) | 0.25, 0.5, 1, 2, 3 |
| **Confidence** | How sure are we about Reach and Impact estimates? | 50%, 80%, 100% |
| **Effort** | Person-weeks of engineering work | 1–20 |

**RICE Score = (Reach × Impact × Confidence) ÷ Effort**

Higher is better. Top 5 by RICE score are our v0.1 scope.

---

## Candidate Features (12 Total)

| # | Feature | Reach | Impact | Confidence | Effort | RICE Score |
|---|---------|-------|--------|------------|--------|------------|
| 1 | Local Voice Agent | 9 | 3 | 90% | 8 | 3.04 |
| 2 | Matter Device Bridge | 10 | 3 | 90% | 10 | 2.70 |
| 3 | Pattern Learning Engine | 7 | 3 | 70% | 12 | 1.23 |
| 4 | Mobile Companion App | 9 | 2 | 80% | 8 | 1.80 |
| 5 | Multi-User Household | 6 | 2 | 80% | 6 | 1.60 |
| 6 | Offline Mode | 8 | 2 | 80% | 5 | 2.56 |
| 7 | Energy Dashboard | 5 | 1 | 70% | 6 | 0.58 |
| 8 | Brand White-Label SDK | 2 | 3 | 60% | 20 | 0.18 |
| 9 | Advanced AI Reasoning | 4 | 3 | 50% | 25 | 0.24 |
| 10 | Security/Surveillance Mode | 5 | 2 | 70% | 8 | 0.88 |
| 11 | IFTTT-Style Workflow Builder | 4 | 2 | 60% | 15 | 0.32 |
| 12 | Developer Skill Store | 3 | 2 | 50% | 20 | 0.15 |

---

## Detailed Scoring Rationale

### Feature 1: Local Voice Agent
- **Reach (9):** Every household uses voice. Without this, Nestra is just a mobile app.
- **Impact (3):** Highest impact on activation and daily WAU. Voice is the primary interaction mode.
- **Confidence (90%):** Local STT (Whisper) is proven. Pi 4 capability is known.
- **Effort (8 weeks):** Significant but manageable. Need to integrate wake word + STT + intent parsing + TTS.
- **RICE: 3.04 — #1**

### Feature 2: Matter Device Bridge
- **Reach (10):** Without device connectivity, nothing else matters. Every household needs this.
- **Impact (3):** Without Matter, we're just a voice app with no devices to control.
- **Confidence (90%):** Matter SDK exists. Integration is well-understood.
- **Effort (10 weeks):** Matter spec is complex. Device commissioning and command routing takes time.
- **RICE: 2.70 — #2**

### Feature 3: Pattern Learning Engine
- **Reach (7):** Power users and family managers both benefit. ~70% of households will engage with patterns.
- **Impact (3):** This is the core differentiator vs Home Assistant. Without learning, we're just voice control.
- **Confidence (70%):** Pattern learning algorithms are proven, but the UX for "learned suggestions" is unproven.
- **Effort (12 weeks):** Behavioral learning is non-trivial. Storage, inference, and UX all need work.
- **RICE: 1.23 — #4 (deprioritized due to effort)**

### Feature 4: Mobile Companion App
- **Reach (9):** Every household has smartphones. App is required for setup and外出 control.
- **Impact (2):** Important for onboarding and out-of-home control, but not the core ambient experience.
- **Confidence (80%):** Flutter app with basic device dashboard is straightforward.
- **Effort (8 weeks):** Significant but well-understood work.
- **RICE: 1.80 — #3**

### Feature 5: Multi-User Household
- **Reach (6):** ~60% of households have multiple adults or children who need access.
- **Impact (2):** Critical for family adoption. One person controlling everything is a single point of failure.
- **Confidence (80%):** Role-based access is a solved problem.
- **Effort (6 weeks):** Moderate. Auth system + role management + parental controls.
- **RICE: 1.60 — #5**

### Feature 6: Offline Mode
- **Reach (8):** Everyone benefits from offline. Internet is unreliable in many homes.
- **Impact (2):** High satisfaction impact. Low frustration when internet goes down.
- **Confidence (80%):** Local-first architecture makes this natural. Not hard, just requires discipline.
- **Effort (5 weeks):** Mostly architectural. Requires not adding cloud dependencies in v0.1.
- **RICE: 2.56 — #2 (tied)*

### Feature 7: Energy Dashboard
- **Reach (5):** Energy-conscious households only. ~50% care enough to check it.
- **Impact (1):** Secondary metric. Nice-to-have but doesn't drive activation or NPS directly.
- **Confidence (70%):** Easy to build after basic device state tracking exists.
- **Effort (6 weeks):** Moderate for a basic version.
- **RICE: 0.58 — Cut from v0.1*

### Feature 8: Brand White-Label SDK
- **Reach (2):** Only 2-3 decor brand partners in v0.1 pilot. Not mass market yet.
- **Impact (3):** High revenue impact per brand, but volume is low at this stage.
- **Confidence (60%):** White-label architecture is complex and poorly understood at this stage.
- **Effort (20 weeks):** Massive. Requires SDK design, sandbox provisioning, admin UX, brand theming.
- **RICE: 0.18 — Cut from v0.1*

### Feature 9: Advanced AI Reasoning
- **Reach (4):** Only power users will leverage complex AI reasoning initially.
- **Impact (3):** Would be highly differentiating if it worked. But current AI is not reliable enough.
- **Confidence (50%):** Causal inference and long-horizon planning are research problems, not product features.
- **Effort (25 weeks):** Massive. Not feasible in v0.1 timeline.
- **RICE: 0.24 — Cut from v0.1*

### Feature 10: Security/Surveillance Mode
- **Reach (5):** ~50% of households care about security features (cameras, door sensors).
- **Impact (2):** Adds peace of mind but doesn't drive core metrics.
- **Confidence (70%):** Straightforward to build on top of Matter sensor devices.
- **Effort (8 weeks):** Moderate. Requires separate compliance review for surveillance data.
- **RICE: 0.88 — Cut from v0.1*

### Feature 11: IFTTT-Style Workflow Builder
- **Reach (4):** Power users only. Most homeowners don't want to build workflows.
- **Impact (2):** Would reduce friction for complex automations, but edge case for v0.1.
- **Confidence (60%):** Workflow builders exist but UX is hard to get right.
- **Effort (15 weeks):** High complexity for uncertain payoff.
- **RICE: 0.32 — Cut from v0.1*

### Feature 12: Developer Skill Store
- **Reach (3):** Developers only. Small audience at launch.
- **Impact (2):** Would help ecosystem but not critical mass at v0.1.
- **Confidence (50%):** Marketplace requires trust, moderation, and ongoing ops investment.
- **Effort (20 weeks):** Ecosystem infrastructure is not free.
- **RICE: 0.15 — Cut from v0.1*

---

## v0.1 Final Scope (Top 5 by RICE)

| Rank | Feature | RICE Score | Justification |
|------|---------|------------|---------------|
| 1 | **Local Voice Agent** | 3.04 | Core interaction mode. Without this, we're just an app. |
| 2 | **Matter Device Bridge** | 2.70 | Core connectivity. Without this, we control nothing. |
| 3 | **Offline Mode** | 2.56 | First principle. Non-negotiable per CEO directive. |
| 4 | **Mobile Companion App** | 1.80 | Onboarding and out-of-home control. Required for activation. |
| 5 | **Multi-User Household** | 1.60 | Critical for family adoption. Required for WAU metric. |

**Pattern Learning Engine (#3 by priority, #4 by RICE)** is deprioritized despite high strategic value because at 12 weeks effort, it pushes the v0.1 timeline too long. It moves to Phase 2.

---

## Deprioritization Reasoning

### Why Pattern Learning (RICE 1.23) is cut despite high priority
Pattern Learning is the single most differentiating feature — it's what separates Nestra from a voice-controlled remote. However:
- **Effort (12 weeks):** This is the single largest effort item and requires behavioral ML expertise we may not have in Phase 1.
- **Risk:** Behavioral learning done wrong creates creepy or annoying experiences (lights turning off when someone is just still).
- **Fallback:** In v0.1, we can do basic time-based rules ("turn off at midnight") without the full ML engine.

**Move to Phase 2:** When we have 50 households of real data, the pattern learning will be far better than anything we can hypothesize in advance.

### Why Energy Dashboard is cut
- **RICE 0.58** — lowest scoring non-cut feature
- Energy data is valuable but requires device-level power consumption reporting, which most Matter devices don't expose
- **Fallback:** Basic device state (on/off) dashboard is included in Mobile Companion App

### Why Brand White-Label SDK is cut
- **RICE 0.18** — lowest scoring feature overall
- This is an Enterprise revenue feature, not a household adoption feature
- Phase 3 focus, after we have product-market fit with homeowners

### Why Advanced AI Reasoning is cut
- **RICE 0.24** — aspirational but not achievable in v0.1
- Current LLM reasoning is too unreliable for home automation guardrails
- We need local inference + rule-based guardrails before we can add AI reasoning

---

## Phase 2 Candidates (What Gets Added After v0.1)

The following features are deferred but documented for Phase 2 roadmap:

| Feature | RICE Score | Readiness Gap |
|---------|------------|---------------|
| Pattern Learning Engine | 1.23 | Needs 12 weeks ML engineering |
| Energy Dashboard | 0.58 | Needs device power data (Matter limitation) |
| Advanced AI Reasoning | 0.24 | Needs local LLM (Llama.cpp integration) |
| Security/Surveillance Mode | 0.88 | Needs compliance review |
| IFTTT-Style Workflow Builder | 0.32 | Needs UX research |

---

## Summary

**v0.1 ships 5 core features:**
1. Local Voice Agent (RICE: 3.04)
2. Matter Device Bridge (RICE: 2.70)
3. Offline Mode (RICE: 2.56)
4. Mobile Companion App (RICE: 1.80)
5. Multi-User Household (RICE: 1.60)

**Total engineering effort:** ~37 person-weeks (8 + 10 + 5 + 8 + 6)

**What we deliberately do not build:** Pattern learning ML engine, brand white-label SDK, complex AI reasoning, energy dashboards, workflow builder, skill store.

---

*Next: See [PRD.md](./PRD.md) for full product requirements and [PERSONAS.md](./PERSONAS.md) for user personas.*
