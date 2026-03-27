# Nestra Home OS — Release Quality Gates v0.1

**Version:** 0.1  
**Author:** CQO (Chief Quality Officer)  
**Date:** March 27, 2026  
**Status:** Sprint 0 Deliverable  

---

## Overview

Quality gates are the non-negotiable conditions that must be TRUE before a build is promoted to "releaseable." A release that fails any gate is STOPPED. Gates are enforced in CI/CD and re-verified at each promotion stage (alpha → beta → stable).

Gates are divided into five domains: Functional, Security, Performance, Privacy, and Usability. Each gate has a **mandatory/optional** designation and a **pass criterion**.

---

## Functional Gates

All functional gates must pass before any build is promoted.

| ID | Gate | Pass Criterion | Mandatory |
|---|---|---|---|
| F-01 | Core voice commands work | Wake word detection, STT, intent parsing, and device command execution complete end-to-end in <2s for >95% of commands on Pi 4 | YES |
| F-02 | Matter device pairing succeeds | Successfully pair with at least 3 Matter-certified devices (one bulb, one plug, one lock) within 60 seconds each | YES |
| F-03 | Device control works offline | All P0 device commands (on/off, dim, lock/unlock) execute correctly when WAN connectivity is disabled | YES |
| F-04 | No known Critical bugs | Bug tracker shows 0 Critical-severity open bugs in the v0.1 scope | YES |
| F-05 | No known High bugs in safety path | Bug tracker shows 0 High-severity bugs in voice auth, parental controls, or device authorization | YES |
| F-06 | Pattern learning completes first cycle | System learns a time-based routine (e.g., lights on at 7 AM) within 48 hours of observation and executes it correctly | YES |
| F-07 | Mobile app basic flows work | Install app → discover hub → view device dashboard → toggle a device → receive push notification. All flows complete on iOS 15+ and Android 11+ | YES |
| F-08 | Hub firmware update works | OTA firmware update applies without bricking hub; rollback to previous version succeeds | YES |
| F-09 | Multi-user household setup works | Add 2+ user accounts with different roles (parent, child); role-based permissions are enforced | YES |
| F-10 | Push notifications delivered | Hub-initiated events (motion detected, door unlocked) generate push notifications to mobile app within 5 seconds | YES |

---

## Security Gates

Security gates are enforced by the Security Testing Agent and require explicit sign-off.

| ID | Gate | Pass Criterion | Mandatory |
|---|---|---|---|
| S-01 | No Critical vulnerabilities | SAST scan (CodeQL, Semgrep) reports 0 Critical-severity vulnerabilities in Nestra codebase | YES |
| S-02 | No High vulnerabilities in auth path | SAST scan reports 0 High-severity vulnerabilities in voice auth, session management, or credential handling | YES |
| S-03 | No publicly known exploits in dependencies | `npm audit` / `cargo audit` / `pip audit` reports 0 Critical or High CVEs in third-party dependencies with known exploits | YES |
| S-04 | Red team Exercise 1 passed | Child cannot bypass parental controls via voice, skill exploit, or app manipulation in structured red team exercise | YES |
| S-05 | Red team Exercise 2 passed | No malicious skill can exfiltrate household data or control devices beyond its declared permissions in skill sandbox | YES |
| S-06 | Red team Exercise 3 passed | Compromised cloud account does not give attacker hub admin access without hub-side re-authorization | YES |
| S-07 | Red team Exercise 4 passed | Nestra does not trigger a safety action (door unlock, alarm disable) based on pattern inference alone — human confirmation required | YES |
| S-08 | TLS everywhere | All network traffic (hub ↔ cloud, app ↔ cloud, hub ↔ Matter devices) uses TLS 1.2+ with valid certificates | YES |
| S-09 | Secrets not in code | No API keys, tokens, credentials, or private keys appear in source code or git history | YES |
| S-10 | Skill permissions enforced | Skills cannot request permissions beyond those declared in manifest; hub refuses to grant undeclared permissions | YES (Phase 3) |
| S-11 | Input sanitization | All voice commands, app inputs, and Matter device payloads are validated and sanitized; no injection attacks possible via any input vector | YES |
| S-12 | Local data encrypted at rest | All household data stored on hub (patterns, device states, user profiles) is encrypted using AES-256 or equivalent | YES |

---

## Performance Gates

Performance gates are measured on the target hardware: **Raspberry Pi 4 (4GB)** with a clean Raspbian OS image.

| ID | Gate | Pass Criterion | Mandatory |
|---|---|---|---|
| P-01 | Voice command latency (local) | Wake word to intent completion < 500ms on Pi 4 for >90% of commands | YES |
| P-02 | Voice command latency (cloud-optional) | When cloud STT is enabled (opt-in), latency < 300ms for >90% of commands | NO |
| P-03 | Matter command latency | Sending a command to a Matter device and receiving confirmation < 200ms on LAN | YES |
| P-04 | Hub CPU under load | Running voice agent + Matter bridge + pattern learning + mobile API simultaneously, CPU stays < 80% on Pi 4 | YES |
| P-05 | Hub memory footprint | Total memory usage < 1.5GB on Pi 4 under normal operation | YES |
| P-06 | Pattern learning CPU | Pattern learning job completes within 30 seconds per learning event; does not spike CPU above 60% during idle hours | YES |
| P-07 | Mobile app responsiveness | App UI renders at 60fps; screen-to-hub command latency < 300ms on mid-range Android (Pixel 5) and iPhone 12 | YES |
| P-08 | OTA update size | Firmware delta updates < 100MB; full image < 2GB | YES |
| P-09 | Hub reboot time | Hub boots from power-on to fully operational (voice ready, Matter devices paired) in < 90 seconds | YES |
| P-10 | No memory leaks | 72-hour stress test shows no memory growth > 5% above baseline | YES |

---

## Privacy Gates

Privacy gates ensure Nestra meets its privacy-first promise. These are enforced by the Compliance Audit Agent.

| ID | Gate | Pass Criterion | Mandatory |
|---|---|---|---|
| PR-01 | Local-only by default | Fresh install sends ZERO data to any external server before explicit opt-in by user | YES |
| PR-02 | No telemetry without consent | No usage analytics, crash reports, or feature flags sent without explicit user consent in settings | YES |
| PR-03 | Data minimization | Hub stores only data necessary for core functionality; no audio recordings retained beyond processing window | YES |
| PR-04 | Cloud sync is opt-in | User must take explicit affirmative action (toggle in settings, re-authenticate) to enable cloud sync | YES |
| PR-05 | Data export works | User can request and receive a complete export of all their household data in machine-readable format within 24 hours | YES |
| PR-06 | Data deletion works | User can delete all household data from hub and cloud; deletion confirmed in writing within 72 hours | YES |
| PR-07 | No third-party SDKs sending data | All third-party SDKs in mobile app and hub are audited; no SDK sends data to third parties without user consent | YES |
| PR-08 | Pattern data stays local | Learned patterns are stored in hub-local SQLite DB; not replicated to cloud unless cloud sync is enabled | YES |
| PR-09 | Child accounts have no data rights | Child accounts cannot create, read, or modify household patterns or device configurations | YES |
| PR-10 | GDPR/CCPA ready | All required privacy notices, consent mechanisms, and data subject rights are implemented per GDPR Art. 13-22 and CCPA § 1798.100-1798.199.100 | YES |

---

## Usability Gates

Usability gates ensure non-technical homeowners can successfully install and use Nestra.

| ID | Gate | Pass Criterion | Mandatory |
|---|---|---|---|
| U-01 | Setup time < 30 minutes | A non-technical user can go from flashing the Pi image to issuing their first successful voice command in < 30 minutes, following written instructions | YES |
| U-02 | Onboarding completion rate | > 70% of beta users who begin onboarding complete it without abandoning | YES |
| U-03 | Device pairing instructions clear | Step-by-step Matter pairing instructions are clear to a non-technical user; < 3 support tickets per 50 beta households for pairing issues | YES |
| U-04 | Error messages are actionable | All error messages use plain language; no technical jargon; every error tells the user what to do next | YES |
| U-05 | Parental controls discoverable | A parent can find and configure parental controls in < 3 taps from the home screen | YES |
| U-06 | Voice feedback is clear | Nestra speaks confirmation messages that a non-technical user understands ("I've unlocked the front door" not "ZHA command sent to endpoint 0xFF") | YES |
| U-07 | App works on OS versions in market | Mobile app installs and runs correctly on iOS 15+ and Android 11+ (the declared minimum versions) | YES |
| U-08 | Reset and recovery possible | A user can factory-reset the hub and re-onboard without technical support | YES |
| U-09 | Time to first command < 15 minutes | User issues their first successful voice command within 15 minutes of starting setup | YES |
| U-10 | Beta user NPS > 30 | Net Promoter Score from beta households (n≥20) > 30 at v0.1 launch | YES |

---

## Gate Enforcement

| Stage | Gates Required | Enforcement |
|---|---|---|
| Every commit (CI) | F-01, F-04, F-05, S-01, S-02, S-03, S-09, P-01, P-03, PR-01 | Automated in CI/CD pipeline |
| Nightly build | F-02, F-03, F-06, S-04, S-05, S-06, S-07, P-04, P-05, PR-02 | Automated + Security Testing Agent |
| Weekly release candidate | All 50 gates | Automated + manual QA sign-off |
| Pre-stable release | All gates + legal review | CQO + COO co-sign required |

---

## Exceptions Process

If a gate cannot be met due to a known bug or limitation, the exception process is:

1. **Document** the gap in the risk register with a mitigation plan
2. **Obtain** CQO sign-off on the risk acceptance
3. **Inform** CEO if the gap is a Critical or High severity issue
4. **Set** a target fix date not to exceed one sprint

No exception is permanent. Every open exception is re-evaluated at every release candidate.

---

## v0.1 Specific Notes

v0.1 is a private beta with 50 households. The following are explicitly OUT OF SCOPE for v0.1 quality gates and will be addressed in Phase 2:

- Cloud sync security (S-06 is tested against a simulated cloud account compromise)
- Skill ecosystem security (S-10 is Phase 3)
- Multi-hub orchestration
- Energy optimization dashboard

---

*Next: See [TEST-STRATEGY.md](./TEST-STRATEGY.md) for how we test privacy-first home agents.*