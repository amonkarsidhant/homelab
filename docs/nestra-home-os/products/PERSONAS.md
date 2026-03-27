# Nestra Home OS — User Personas v0.1

**Version:** 0.1  
**Author:** CPO (Chief Product Officer)  
**Date:** March 27, 2026  

---

## Persona 1: Priya Sharma — The Family Manager

### Demographics
- **Age:** 38
- **Role:** IT Manager at a healthcare company, mother of two (ages 8 and 12)
- **Location:** Suburban Chicago, 3-bedroom home, dual-income household
- **Tech Comfort:** Medium — comfortable with smartphones and smart TV setup, but has never touched Home Assistant or any automation tools

### Current Smart Home Setup
- 4 Philips Hue bulbs (living room, kitchen)
- Amazon Echo Show in kitchen (used for timers and recipe queries)
- Nest Thermostat (installed by HVAC company)
- Two smart plugs for Christmas decorations

### Goals and Frustrations

**What she wants from a smart home:**
- "I want my home to just work. I don't want to have to think about the lights or the thermostat."
- Set up routines without calling her husband or reading documentation
- Know her kids are safe (locks, smoke detectors alerts)
- Get peace of mind when she's traveling for work

**Current frustrations with smart home solutions:**
- "Every device has its own app. I'm not going to open 5 different apps to turn off the living room lights."
- Voice assistants are "funny about background noise" — they misfire during movie time
- No visibility into what's actually happening — did the kids remember to lock the front door?
- "My husband keeps saying we should get Home Assistant but I don't want to learn to code our own house"
- Privacy concerns — she doesn't want everything going through Amazon or Google servers

### How She'd Use Nestra

**Day 1 onboarding:**
- "Hey Nestra, find my devices"
- Nestra discovers Hue bulbs and Nest thermostat
- Priya: "Organize them by room"
- Done — no app, no YAML, no configuring

**Daily interactions:**
- "Hey Nestra, I'm going to work" → Nestra locks doors, sets thermostat to away mode
- "Hey Nestra, movie time" → Nestra dims living room lights, turns off kitchen lights
- "Hey Nestra, did the kids get home from school?" → Motion sensor check, notification

**Weekly maintenance:**
- Priya opens the app once a week to check the Pattern Insights card: "Your living room lights have been on past midnight 4 times this week. Should I set an auto-off?"
- She approves or dismisses — no manual configuration

### What "Trust" Means to Her

1. **Privacy trust:** Her data stays in her home. She wants proof — not a privacy policy she has to read, but a technical architecture she can understand.
2. **Reliability trust:** Nestra does what it says. If she says "lock the doors," the doors are locked. If it can't, it tells her immediately.
3. **Parental trust:** She needs to know her kids can't bypass safety settings by asking Nestra nicely. No voice command should unlock a door if parental controls are on.
4. **Brand trust:** She doesn't know Nestra as a startup. If IKEA or Wayfair offers it, she trusts it because she already trusts the store.

---

## Persona 2: Marcus Chen — The Power User

### Demographics
- **Age:** 42
- **Role:** Staff Software Engineer at a fintech startup
- **Location:** Seattle, condo (900 sq ft, open floor plan)
- **Tech Comfort:** Very high — builds side projects in Rust, has Home Assistant running on a dedicated mini-PC, 40+ automations

### Current Smart Home Setup
- Home Assistant OS on a Intel NUC (always-on)
- Zigbee2MQTT bridge with 20+ devices
- ESPHome sensors (temperature, motion, door)
- Fully voice-controlled via Alexa (custom Alexa routines)
- Fully self-hosted — no cloud dependencies

### Goals and Frustrations

**What he wants from a smart home:**
- "I want to own my data. My home data should not be on someone else's servers."
- Full control — he wants to be able to audit every decision Nestra makes
- Integration with his existing Home Assistant setup (not replacement)
- The ability to contribute back — open-source skill development

**Current frustrations:**
- Home Assistant is powerful but "it's a hobby, not a product" — weekend maintenance, YAML debugging, plugin compatibility
- "Voice control in HA is janky. Alexa routines are a hack on top of a hack."
- No ambient intelligence — he has to explicitly program every automation. His home doesn't anticipate.
- "My partner refuses to touch any of it because it's too technical. She just wants it to work."

### How He'd Use Nestra

**Day 1 onboarding:**
- Marcus manually configures all his Home Assistant devices into Nestra via config file
- He enables debug logging immediately
- He reads the local inference source code to verify privacy claims
- He writes a custom skill to expose his ESPHome sensor data to Nestra

**Daily interactions:**
- "Hey Nestra, status" → List of all device states, recent events, any anomalies
- He uses Nestra voice to trigger complex Home Assistant scripts via command line
- He reviews pattern learning outputs and manually approves/rejects them

**Advanced usage:**
- He forks the Nestra skill SDK and builds a custom energy monitoring skill
- He contributes it back to the community after 3 months of internal use
- He attends the Nestra developer forum to discuss architecture decisions

### What "Trust" Means to Him

1. **Source trust:** He will read the code. If he can't, he doesn't trust it. Nestra must be open-source or have a verifiable open-source core.
2. **Data trust:** He wants to know exactly where his data flows. If there's a cloud sync, it must be explicit, opt-in, and auditable.
3. **Control trust:** He can disable or override any behavior. Nestra is his agent, not his replacement.
4. **Community trust:** If Nestra has a thriving developer community, he trusts it more. Dead projects are untrustworthy.

---

## Persona 3: Jordan Ellis — The Brand Ops Manager

### Demographics
- **Age:** 34
- **Role:** Director of Product Innovation at a mid-size decor brand (~$2B revenue, 400 retail locations)
- **Location:** Remote-first, based in Austin, TX
- **Tech Comfort:** Medium-low — understands product management, knows enough to be dangerous with technical teams, but doesn't code

### Role in the Organization
- Owns the "smart home" product roadmap for the brand
- Coordinates between engineering (internal or outsourced), design, and retail partners
- Reports to CMO, works closely with supply chain for connected device SKUs
- **Budget authority:** Can approve up to $500K for technology partnerships

### Goals and Frustrations

**What their brand wants:**
- Offer a "smart home" story without hiring 500 engineers
- Differentiate from competitors who are all doing the same app + voice assistant
- Collect anonymized, aggregated home environment data (opt-in) for product insights
- Drive retail traffic — smart home bundles sold in-store

**Current frustrations:**
- Building software is not their core competency — every internal app is mediocre at best
- Existing white-label options (Flex, Athos) are expensive and require deep technical integration
- "Our customers don't want another app. How do we meet them where they already are?"
- Privacy regulations are a minefield — they can't afford a data breach or GDPR violation
- Timeline pressure: board wants "smart home" announced in 18 months

### How They'd Use Nestra

**Week 1 — Evaluation:**
- Jordan reviews Nestra Enterprise documentation
- Schedules a technical call with Nestra engineering to discuss white-label architecture
- Asks for a sandbox environment to demo internally

**Month 1-3 — Pilot:**
- Nestra Enterprise provisions a sandbox for their internal lab
- Jordan's team tests white-label theming (brand colors, voice name, app icon)
- They do a small pilot: 10 employees, 3 device SKUs (lamp, plug, thermostat)

**Month 4-6 — Retail Launch:**
- Launch in 50 stores as a "smart home starter kit" (brand hub + 2 devices)
- Nestra is re-skinned as "[Brand] Home" — same Nestra brain, brand voice
- Jordan monitors dashboards: activation rate, device sales correlation, NPS
- Pilot data goes to CMO for board presentation

### What "Trust" Means to Them

1. **Enterprise trust:** Nestra Enterprise must have SOC 2 Type II certification, GDPR compliance, and clear data handling terms before they can sign a contract.
2. **Brand safety trust:** Nestra must never do anything that damages their brand — no inappropriate content, no anti-brand sentiment from the voice agent.
3. **Operational trust:** If Nestra goes down, their customer support gets calls. They need SLA guarantees (99.9% uptime minimum) and clear escalation paths.
4. **Revenue trust:** The smart home bundle must drive measurable retail lift. Jordan needs attribution data.

---

## Persona Summary

| Persona | Primary Need | Trust Trigger | Deal Breaker |
|---------|--------------|---------------|--------------|
| **Priya (Family Manager)** | Convenience + peace of mind | It just works, privacy guaranteed, kid-safe | If it requires reading a manual |
| **Marcus (Power User)** | Control + transparency | Open source, local-only, auditable | If it's a black box |
| **Jordan (Brand Ops)** | Speed to market + brand safety | Enterprise compliance, SLA, measurable ROI | If it can't be white-labeled in 6 months |

---

*Next: See [FEATURE-MATRIX.md](./FEATURE-MATRIX.md) for RICE-scored feature prioritization, and [PRD.md](./PRD.md) for the product requirements.*
