# Nestra Home OS — Product Requirements Document v0.1

**Version:** 0.1  
**Author:** CPO (Chief Product Officer)  
**Date:** March 27, 2026  
**Status:** Draft for Sprint 0 Review  

---

## The Compelling Answer

> **"What is the single most compelling reason a homeowner would install Nestra instead of just using Home Assistant + voice assistants they already have?"**

**The honest answer:** In v0.1, the compelling reason is weak. Home Assistant + Alexa/Google Home already covers 80% of what we're building. 

**The real compelling reason we must build toward:** Nestra is the only platform that provides **ambient contextual reasoning across the whole home** — not just voice control of individual devices, but an AI that understands the home as a system: *"The family is asleep, the living room lights are on but no motion detected for 2 hours, the thermostat is still at 72°F — should I turn these off and save energy, or is someone just very still on the couch?"* Home Assistant can automate that workflow if you write the automation. Nestra will ask the question and learn the family's preference.

**Why this is weak right now:** In v0.1, we're not actually building the contextual reasoning engine. We're building the foundation — local voice, Matter bridge, pattern learning. The full ambient intelligence is Phase 2. So the honest pitch for v0.1 is: *"A voice-controlled home hub that works offline, respects your privacy, and learns your patterns over time — without a subscription and without big tech silos."*

**What makes this stronger in v1.0:** When Nestra can say *"I noticed you always turn on the porch light at 6:14 PM when it's dark outside. Want me to automate that?"* — and actually follow through without the user touching YAML — that's when we have a defensible moat.

---

## 1. Product Vision

Nestra Home OS is an **ambient home intelligence platform** — a privacy-first AI layer that runs locally on homeowner hardware (Raspberry Pi, NAS), connects to any Matter device, and learns family patterns to anticipate needs without requiring the family to be home automation engineers.

For decor brands (IKEA, Wayfair, Ashley), Nestra is a white-label "smart home brain" they can offer in stores and apps without building software.

For homeowners, Nestra is the home they've always wanted — one that listens, learns, and just works.

---

## 2. Target Users

Nestra serves three distinct user groups, each with different primary motivations:

| User Group | Primary Motivation | Revenue Model |
|------------|---------------------|---------------|
| **Family Members** (homeowners, parents) | Convenience, peace of mind, privacy | Free tier → Home+ subscription |
| **Power Users** (tech-savvy, automators) | Control, customization, self-hosting | Home+ subscription ($9.99/mo) |
| **Brand Ops** (decor brand employees) | Deploying smart home experiences at scale | Enterprise OEM license |

---

## 3. Core Features for v0.1

Features are ordered by priority. We ship all 7 or cut the lowest priority if timeline slips.

### P0 — Must Have

1. **Local Voice Agent**
   - Wake word detection ("Hey Nestra")
   - Local speech-to-text and intent parsing (no cloud required)
   - Natural language commands and queries
   - Runs on Raspberry Pi 4 (target hardware)

2. **Matter Device Bridge**
   - Discover and pair Matter devices
   - Issue commands (on/off, dim, color, temperature)
   - Read device state
   - Works with IKEA, Nanoleaf, TP-Link, and other Matter-certified devices

3. **Mobile Companion App (iOS + Android)**
   - Device dashboard (all connected devices at a glance)
   - Room-based organization
   - Manual control (tap to toggle)
   - Push notification for important events

4. **Pattern Learning Engine (v0.1)**
   - Learns time-based routines ("every weekday at 7 AM, turn on kitchen lights")
   - Learns presence patterns ("no motion in living room for 3 hours → turn off lights")
   - Stores patterns locally, not in cloud
   - User can view and delete learned patterns

5. **Local Inference Runtime**
   - Agent brain runs 100% locally on edge hardware
   - No mandatory cloud dependency
   - Cloud sync optional (for Home+ tier)

### P2 — Should Have

6. **Multi-User Household**
   - Up to 6 family members per household
   - Role-based access (parent, child, guest)
   - Parental controls (curfew, device restrictions for child accounts)
   - Shared device access

7. **Offline Mode**
   - Home continues to work when internet is down
   - Voice commands, automations, and pattern-based actions all function offline
   - Syncs cloud state when connectivity restores

---

## 4. What We Are NOT Building in v0.1

The following are intentionally excluded from v0.1 and reserved for future phases:

| Excluded Feature | Reason | Planned Phase |
|------------------|--------|---------------|
| Cloud sync + subscription features | Need v0.1 stable first | Phase 2 |
| Brand white-label SDK | Requires product-market fit | Phase 3 |
| Multi-hub orchestration (whole-home mesh) | Single hub is complex enough | Phase 2 |
| Energy optimization dashboard | Nice-to-have, not differentiating | Phase 2 |
| Advanced AI reasoning (causal inference, long-horizon planning) | Not technically feasible in v0.1 timeline | Phase 3+ |
| Security/surveillance monitoring | Requires separate compliance work | TBD |
| IFTTT-style complex workflow builder | End-user facing, too high risk for v0.1 | Phase 2 |
| Smart home skill store / third-party skills | Ecosystem play, requires marketplace first | Phase 3 |
| Natural language automation authoring ("tell me how to...") | High complexity, low maturity | Phase 3 |

---

## 5. Success Metrics

We define success for v0.1 (private beta, 50 households) with the following targets:

| Metric | Definition | v0.1 Target | Notes |
|--------|------------|-------------|-------|
| **Activation Rate** | % of users who flash the Pi image and complete onboarding | >70% | If users can't get it running, nothing else matters |
| **Weekly Active Households (WAU)** | % of activated households using Nestra at least once/week | >50% | Target: >30% is acceptable for v0.1 |
| **Net Promoter Score (NPS)** | "How likely are you to recommend Nestra?" (0-10) | >40 | Indicates product-market fit before scaling |
| **Time to First Command** | Minutes from flash to first successful voice command | <15 min | Critical UX metric |
| **Device Pairing Success Rate** | % of attempted Matter device pairings that succeed | >85% | Depends on Matter certification |
| **Voice Intent Accuracy** | % of voice commands correctly understood and executed | >90% | Local STT must be tuned per hardware |
| **Offline Capability** | % of core commands that work without internet | 100% | Non-negotiable per first principles |

---

## 6. Open Questions

The following must be answered before or during Phase 1:

### Product
1. **Minimum viable device set for testing:** Which 3-5 Matter devices should we certify against for v0.1? (IKEA bulb + plug, Nanoleaf, TP-Link plug minimum)
2. **Onboarding UX:** How do we guide non-technical homeowners through flashing a Raspberry Pi without losing 50% of them at step 1?
3. **Pattern learning UX:** Where do users see learned patterns? How do they delete wrong ones? (v0.1 needs at least a basic UI for this)
4. **Family member onboarding:** How does a spouse or teen join the household? QR code? NFC tap?

### Technical
5. **Voice STT performance on Pi 4:** Is Whisper tiny-enough fast enough for real-time (<500ms latency) on Raspberry Pi 4? If not, what's the minimum hardware tier?
6. **Matter controller vs Matter bridge:** We need to decide if Nestra is a Thread border router, a Matter controller, or both. This affects hardware requirements.
7. **Memory footprint:** How many Matter devices can a Pi 4 handle before latency becomes unacceptable?

### Business
8. **White-label pricing:** What should the OEM license cost per household/month? Need CRO input before Phase 2.
9. **Brand partnership motion:** Do decor brands want to white-label Nestra, or do they want to embed our API in their own app? The answer changes the technical architecture.
10. **Competitor differentiation:** Home Assistant has a 5-year head start and a passionate community. Our differentiation is UX + privacy + brand partnerships. Is that enough to break through?

---

## 7. Assumptions

This PRD is based on the following assumptions, which must be validated in Sprint 0 and Phase 1:

1. Raspberry Pi 4 is sufficient for local voice + Matter hub (if not, we need to specify Pi 5 or mini PC)
2. Matter specification is stable enough for production integration (Matter 1.2+)
3. Privacy-first positioning resonates with mainstream homeowners (not just tech enthusiasts)
4. Decor brands will pay for OEM white-label (not just want it for free)
5. Home Assistant OS is NOT a direct competitor — we target non-technical homeowners, HA targets automators

---

*Next: See [PERSONAS.md](./PERSONAS.md) for detailed user personas and [FEATURE-MATRIX.md](./FEATURE-MATRIX.md) for RICE-scored feature prioritization.*
