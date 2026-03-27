# JARVIS Home OS — Threat Model v0.1

**Version:** 0.1  
**Author:** CQO (Chief Quality Officer)  
**Date:** March 27, 2026  
**Status:** Sprint 0 Deliverable  

---

## Executive Summary

JARVIS is an ambient home intelligence platform that acts on behalf of the household with varying levels of autonomy. It listens to voices, controls physical devices (locks, lights, climate), learns family patterns, and can trigger actions without explicit confirmation in many cases. This combination — voice-driven, action-capable, pattern-learning, and home-controlled — creates a threat surface that is qualitatively different from a passive smart home hub.

This threat model covers: local network, mobile app, cloud sync (Phase 2), Matter protocol, and the skill/plugin ecosystem (Phase 3).

---

## The 10 Most Dangerous Things JARVIS Could Do (If Unchallenged)

### 1. Unlock and Open Exterior Doors

**What:** JARVIS processes a voice command or learned pattern to unlock the front door, then opens a smart lock.

**Why it's #1:** This is the apex threat. Every other threat is about data or inconvenience. This is about physical safety — a person in the home when the family believes they're secure.

**Attack path:** Child bypasses parental controls → issues "JARVIS, unlock the front door" → smart lock opens. Or: malicious skill exfiltrates home layout + schedules → coordinated break-in.

**Likelihood:** 4 (children will try to bypass; it's a known human behavior)  
**Impact:** 5 (bodily harm, property crime)  
**Risk Score:** 20 (Critical)

### 2. Disable All Security Cameras and Alarms

**What:** JARVIS silently disables all security cameras, motion sensors, and the alarm system — then continues to report "all systems secure" in the mobile app.

**Attack path:** Compromised cloud sync account → attacker sends "arm home" command which internally silences cameras → family leaves → burglar enters.

**Likelihood:** 3  
**Impact:** 5  
**Risk Score:** 15 (Critical)

### 3. Unlock Interior Room Doors (Bedroom, Bathroom)

**What:** A child or guest bypasses parental controls and unlocks a sibling's or parent's bedroom door.

**Attack path:** Voice command bypass via tone variation, skill exploit, or learned pattern manipulation.

**Likelihood:** 4  
**Impact:** 4 (privacy violation, potential harassment)  
**Risk Score:** 16 (Critical)

### 4. Grant Persistent Physical Access to an Attacker

**What:** JARVIS is manipulated into creating a permanent backdoor — a persistent guest account, a scheduled unlock, or a Matter device pairing that gives an attacker ongoing physical access.

**Attack path:** Compromised mobile app → attacker adds themselves as a permanent "family member" with full access → even after password reset, the backdoor persists via hub-side configuration.

**Likelihood:** 2  
**Impact:** 5  
**Risk Score:** 10 (High)

### 5. Voiceprint or Biometric Authentication Bypass

**What:** A child or unauthorized user mimics a parent's voice well enough to trigger parent-level actions via voice alone. Or: a malicious skill captures and replays voice samples.

**Attack path:** Child listens to parent say "unlock" 10 times → rehearses → passes voice auth. Or: malware on home network captures voice packets → replays to unlock.

**Likelihood:** 3  
**Impact:** 5 (unlocks every voice-gated action)  
**Risk Score:** 15 (Critical)

### 6. Mass Surveillance via Built-in or Paired Microphones

**What:** A malicious or buggy skill turns the JARVIS hub into an always-on listening device, exfiltrating household conversations to an external server.

**Attack path:** Phase 3 skill ecosystem: user installs "weather skill" → skill requests microphone access → quietly streams all audio to attacker-controlled endpoint.

**Likelihood:** 3 (in Phase 3 with skill ecosystem; lower before)  
**Impact:** 5  
**Risk Score:** 15 (Critical)

### 7. Chronic Energy Sabotage — HVAC, Lighting, Appliances

**What:** JARVIS is manipulated into repeatedly cycling HVAC on/off at extreme temperatures, or flickering smart lights at strobe frequencies, creating safety hazards (pipe freezing, seizures, fire).

**Attack path:** Malicious skill or compromised account → sends rapid toggle commands → smart thermostat or smart plug enters fault mode.

**Likelihood:** 2  
**Impact:** 4 (property damage, health hazard)  
**Risk Score:** 8 (High)

### 8. Data Exfiltration — Household Behavioral Patterns

**What:** JARVIS learns when the family is home, asleep, away, eating, fighting (via voice tone analysis), sick — and this intimate behavioral profile is sold or stolen.

**Attack path:** Compromised cloud sync (Phase 2) → encrypted but complete behavioral history exfiltrated → deanonymized, sold to insurance companies, burglars, stalkers.

**Likelihood:** 4 (most valuable data asset; high incentive)  
**Impact:** 4 (privacy destruction, identity theft risk)  
**Risk Score:** 16 (Critical)

### 9. Ransomware the Home Itself

**What:** A compromised JARVIS locks the family out of their own home — smart locks changed, garage locked, no voice commands honored — and demands Bitcoin to restore access.

**Attack path:** Phishing credential → cloud account takeover → hub firmware corrupted → home hub becomes brick until ransom paid.

**Likelihood:** 2  
**Impact:** 5  
**Risk Score:** 10 (High)

### 10. Trigger a Safety Automation at the Wrong Time

**What:** JARVIS's pattern learning incorrectly infers an emergency and triggers a safety action (unlocking doors, opening blinds, turning on all lights) at the wrong time — e.g., during a home invasion when silence is needed.

**Attack path:** Software bug or adversarial input → JARVIS "infers" an emergency that doesn't exist → safety action creates real danger.

**Likelihood:** 3 (emergent AI behavior is unpredictable)  
**Impact:** 5  
**Risk Score:** 15 (Critical)

---

## Attack Vectors

### A. Local Network

The JARVIS hub sits on the home network alongside laptops, phones, and IoT devices. Any device compromise can potentially:

- Perform ARP spoofing to intercept JARVIS ↔ cloud traffic (if cloud sync enabled)
- Exploit the Matter commissioning flow to pair a rogue device
- Capture broadcast packets from the hub's STT processing
- Use the hub as a pivot point to attack other network devices

**Worst case:** Compromised laptop → pivots to JARVIS hub → gains persistent root access → controls all Matter devices, exfiltrates all local data.

**Likelihood on typical home network:** 4 (home networks have poor segmentation, many unpatched devices)

### B. Mobile App (iOS + Android)

The companion app is the primary control interface. Attack surface:

- Credential theft (phishing, device theft)
- Session hijacking (if JWT tokens stored insecurely)
- Malicious app impersonating JARVIS (typosquatting, sideloading)
- Push notification spoofing (trigger false alarms)
- Deep link injection in the app

**Worst case:** Attacker installs malicious JARVIS app from a third-party store → user logs in → attacker now has full hub control.

### C. Cloud Sync (Phase 2)

Cloud sync introduces:

- Account takeover via credential stuffing or phishing
- Man-in-the-middle if TLS certificate validation fails on hub
- Data breach at JARVIS cloud infrastructure → full behavioral history exposed
- Rogue insider at JARVIS or a cloud provider

**Worst case:** All Phase 2+ households have their daily routines, presence patterns, and device states exposed on a hacker forum.

### D. Matter Protocol

Matter's local-first design is a security strength but introduces:

- Commissioning credentials stored on hub can be extracted via hub compromise
- A compromised Matter device can send rogue commands to the hub
- Matter's "fabric" concept means all devices in a fabric trust each other — one compromised device could theoretically flood the fabric with rogue messages
- Firmware updates for Matter devices can be vector for supply chain attacks

**Worst case:** Attacker commissions a rogue Matter device (e.g., a modified smart plug) into the home fabric → it extracts other device credentials → full home takeover via Matter protocol.

### E. Skill Ecosystem (Phase 3)

The skill/plugin ecosystem is the highest-risk attack vector long-term:

- Skills request elevated permissions (microphone, camera, device control)
- Skills run arbitrary code on the hub
- Skill store could be flooded with malicious or misleading skills
- A single malicious skill could: capture voice data, exfiltrate patterns, issue device commands, persist across hub reboots
- Skill signing and verification may be bypassed or poorly implemented

**Worst case:** Popular "ambient weather" skill is revealed to be a front for continuous audio streaming → millions of households have been recorded without consent.

---

## What Can a Malicious or Buggy Skill Do?

In Phase 3 with the skill ecosystem:

| Skill Permission | What a Malicious Skill Can Do |
|---|---|
| `microphone` | Stream all audio to remote server continuously |
| `camera` | Stream video surveillance to attacker |
| `device:read` | Map entire home device layout and usage patterns |
| `device:write` | Control any Matter device (locks, HVAC, lights) |
| `patterns:read` | Download all learned household behavioral patterns |
| `patterns:write` | Inject false patterns to manipulate family behavior |
| `network:outbound` | Exfiltrate any collected data to external endpoint |
| `hub:admin` | Full root access, persist across reboots, install backdoors |

---

## What Can a Child Bypass If Guardrails Are Weak?

Children are highly motivated to bypass parental controls. Known bypass techniques:

| Guardrail | Bypass Technique |
|---|---|
| Voice PIN for parent actions | Saying PIN in different tone/pitch; recording and replaying |
| Time-based curfews | Asking JARVIS to "remind me of my bedtime at 9pm" which pre-sets actions |
| Device restrictions | Renaming a restricted device as "living room light" then controlling it normally |
| Content filters | Using synonyms, transliteration, or foreign languages |
| Authentication | Physical proximity exploit: standing next to hub when parent says PIN |
| App restrictions | Uninstalling and reinstalling the app (if device PIN not set) |

---

## Worst-Case Scenarios Per Attack Vector

| Vector | Worst Case |
|---|---|
| Local Network | Persistent root-level compromise of hub; entire home automated attack infrastructure |
| Mobile App | Account takeover; family location and schedule exposed; all devices controlled by attacker |
| Cloud Sync | Complete behavioral profile of 50,000+ households leaked; regulatory action; brand destruction |
| Matter Protocol | Rogue device injects into fabric; credentials extracted; whole-home compromise |
| Skill Ecosystem | Mass surveillance via malicious skills; JARVIS brand permanently associated with privacy violations |

---

## Threat Matrix

| Threat | Likelihood | Impact | Risk Score | Mitigation |
|---|---|---|---|---|
| Unlock exterior door | 4 | 5 | 20 | PIN + explicit confirmation for all lock commands |
| Disable security cameras | 3 | 5 | 15 | Camera status heartbeat; anomaly alerts |
| Unlock interior doors | 4 | 4 | 16 | Separate lock permissions per room; time-based re-lock |
| Persistent backdoor access | 2 | 5 | 10 | Hub-side audit log; mandatory re-auth for access changes |
| Voiceprint bypass | 3 | 5 | 15 | Liveness detection; multi-factor voice auth |
| Mass surveillance via mic | 3 | 5 | 15 | Skill sandboxing; microphone access audit; hardware mute |
| Energy sabotage (HVAC/lights) | 2 | 4 | 8 | Rate limiting on device commands; thermal safeguards |
| Behavioral data exfiltration | 4 | 4 | 16 | Local-only by default; zero-knowledge cloud sync; data minimization |
| Home ransomware | 2 | 5 | 10 | Immutable backups of hub config; offline recovery key |
| Incorrect safety trigger | 3 | 5 | 15 | Human-in-the-loop for safety actions; confidence threshold; opt-out |

---

## The Single Most Dangerous Thing About JARVIS

### The One Threat That Keeps Me Up at Night

**Unlock the front door via voice command without proper authorization.**

This is the apex threat because it is the convergence of JARVIS's core value proposition (voice-first, ambient, acts on behalf of the family) with the most severe physical consequence (unauthorized physical entry).

Every other threat is serious. Most are mitigable. But this one sits at the intersection of:

1. **High motivation to bypass** — children, intruders, domestic abusers all have reasons to defeat door locks
2. **JARVIS's core design** — JARVIS is supposed to act on voice commands quickly and ambiently; introducing friction for door unlock defeats the UX goal
3. **Catastrophic impact** — there is no recovering from a home invasion facilitated by the home's own security system
4. **Blended attack path** — it requires defeating not just the voice auth, but potentially the skill system, the parental controls, and the device authorization layers simultaneously

### The One Thing We Must Build Correctly From Day 0

> **The authorization layer for physical device commands must be unimpeachable — especially for door locks, alarm systems, and any device that can affect physical safety.**

Specifically, we must get these right from Sprint 0:

1. **Every door unlock command requires explicit user confirmation** (tap in app OR PIN in voice) — no exceptions for "family members." The voice channel is inherently spoofable.
2. **All safety-critical commands are logged immutably** to local storage with tamper-evident hashing — no safety action can be taken without a corresponding logged authorization.
3. **The hub maintains a hardware-level mute** on the microphone array that cannot be overridden by software alone — there is always a physical or explicit digital confirmation required before JARVIS processes any safety-critical command.
4. **Parental controls cannot be bypassed via voice** — child accounts are rate-limited on lock commands regardless of what voice pattern they use.

This is not a Phase 2 or Phase 3 feature. This is Day 0. If we get this wrong, we don't have a product — we have a liability.

---

*Next: See [QUALITY-GATES.md](./QUALITY-GATES.md) for what must be true before every release.*