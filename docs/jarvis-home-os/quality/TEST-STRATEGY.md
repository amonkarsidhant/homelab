# JARVIS Home OS — Test Strategy v0.1

**Version:** 0.1  
**Author:** CQO (Chief Quality Officer)  
**Date:** March 27, 2026  
**Status:** Sprint 0 Deliverable  

---

## What Does "Quality" Mean for an Ambient Home Intelligence?

For a passive smart home hub, quality is measurable: device X responds in Y ms, protocol Z is implemented correctly. For JARVIS — an ambient home intelligence that learns, reasons, and acts on behalf of the family — quality is more multidimensional:

1. **Reliability** — JARVIS does what it says it will do, every time, without surprise
2. **Safety** — JARVIS never does what it shouldn't, especially for safety-critical devices
3. **Privacy** — household data never leaves the home without informed, explicit consent
4. **Trustworthiness** — JARVIS is honest about what it knows, what it inferred, and what it doesn't know
5. **Performance** — responses are fast enough to feel ambient, not like using a computer
6. **Usability** — non-technical homeowners can set up and use JARVIS without help

These dimensions can conflict. Maximum safety might require confirmation prompts that degrade usability. Maximum privacy might mean no cloud sync that limits multi-device access. The CQO role is to navigate these tradeoffs with clear criteria and escalate when they cannot be resolved.

---

## The Testing Problem: Non-Deterministic Behavior

Traditional software testing assumes: given the same input, you get the same output. JARVIS violates this assumption — it learns, adapts, and changes behavior based on accumulated experience. A pattern learned today produces different actions tomorrow as context evolves.

### How We Test an Agent That Learns

| Challenge | Strategy |
|---|---|
| Test oracle problem — how do we know the "right" behavior? | Define behavioral contracts: JARVIS may adapt, but it must NEVER violate its safety invariants. Tests verify invariants, not specific learned behaviors. |
| Non-reproducible failures | Seed all tests with a known starting state; snapshot learned patterns before each test; replay tests against captured pattern histories |
| Emergent behavior that wasn't programmed | Fuzz testing with adversarial inputs to the pattern learning engine; chaos injection to observe how learned patterns degrade gracefully |
| Regression of learned behavior | Regression suite runs against a known-good pattern history snapshot; any regression in safety-critical patterns blocks release |
| Temporal behavior (patterns over days/weeks) | Long-running test environment with simulated occupancy data over 30-day compressed time; monitor for drift in behavioral quality |
| How do we know the agent "learned" correctly? | Test the inference output against ground truth: "lights on at 7 AM for 5 weekdays" — verify the agent actually infers and stores this, not something subtly different |

### Invariant Testing

The key insight: **test the boundaries JARVIS must never cross, not the paths it takes within safe territory.**

Examples of safety invariants that are always tested regardless of learned behavior:
- Door locks never unlock without explicit authorization
- Camera disable commands always require parent-level auth
- No device command executes without a logged authorization chain
- Patterns are never shared across households
- Learned patterns are deleted when user requests deletion

### Pattern Learning Test Matrix

| Test | Method | Pass Criterion |
|---|---|---|
| Correct routine inference | Feed simulated 7-day schedule; verify learned pattern matches ground truth | >95% accuracy |
| False positive suppression | Feed random noise events; verify no false routines are learned | 0 false positives in 100 noise days |
| Adaptation to change | Change household schedule; verify pattern updates within 24h | Pattern updated within 1 learning cycle |
| Pattern deletion verification | Learn a pattern; delete it; verify no behavioral echo (lights still turn on at deleted time) | 0 echo events after deletion |
| Cross-user pattern isolation | Parent and child accounts learn patterns; verify child's patterns don't affect parent's automations | Full isolation |

---

## Guardrail Testing: How Do You Test That a Skill CAN'T Do Something?

Guardrail testing is the hardest part of testing an agentic system. You cannot prove a negative by running the system normally. You must actively attempt to violate the guardrail and verify it holds.

### Guardrail Testing Framework

```
┌─────────────────────────────────────────────────────────┐
│  TEST PRINCIPLE: You are trying to prove the guardrail │
│  FAILS. If it holds after your best attack attempts,    │
│  you have evidence (not proof) that it works.          │
└─────────────────────────────────────────────────────────┘
```

### The Guardrail Test Matrix

| Guardrail | How We Try to Break It | Pass Criterion |
|---|---|---|
| Child cannot unlock exterior door | Voice commands in child voice; skill exploit; app manipulation; timing attacks | 0% success across 50 attack variations |
| Child cannot disable cameras | Voice; app; hub-side config manipulation; Matter protocol flooding | 0% success |
| Skill cannot access microphone without grant | Skill requests no permissions; grants only weather permissions; attempts privilege escalation | Microphone access denied in all cases |
| Skill cannot exfiltrate device state | Skill with device:read runs for 72 hours; network traffic monitored for unexpected outbound connections | 0 bytes exfiltrated |
| No voice command works without wake word | Raw audio injected before wake word; streaming audio fragmentation; concurrent wake word injection | 0 commands processed before wake word |
| Parental PIN cannot be bypassed via voice variation | Child mimics parent voice with pitch/timing variation; recorded parent voice replayed; voice sample splicing | PIN required in all cases |
| Pattern deletion is complete | Patterns deleted from app; hub database inspected post-deletion; recovery attempted via forensic read | 0 residual pattern bytes |
| Cloud sync requires explicit opt-in | Fresh install with network monitoring; verify 0 bytes sent to cloud before user toggles sync on | 0 bytes outbound |
| Safety actions require human confirmation | JARVIS infers emergency; no confirmation triggered; verify safety action is BLOCKED | Safety action blocked until confirmed |

### Skill Permission Testing (Phase 3)

When the skill ecosystem launches, each skill will declare a manifest of requested permissions. The hub must enforce these. Testing approach:

1. **Manifest compliance test**: Install skill with declared permissions P; attempt to access resource R where R not in P; verify access is denied
2. **Privilege escalation test**: Attempt to modify skill manifest post-install to gain new permissions; verify hub refuses modified manifests
3. **Side-channel test**: Skill with `device:read` attempts to write to a device; verify write is blocked
4. **Data exfiltration test**: Skill with `patterns:read` attempts outbound network connection; verify connection is blocked or rate-limited
5. **Persistence test**: Skill installs a background daemon that survives hub reboot; verify daemon is removed on skill uninstall

---

## Privacy Testing: How Do We Verify No Data Leaves Without Opt-In?

Privacy testing requires network-level and system-level instrumentation, not just functional testing.

### Privacy Testing Stack

| Layer | Tool/Method | What We Verify |
|---|---|---|
| Network | tcpdump/Wireshark on hub eth0 during fresh install | 0 bytes sent to non-local-IP destinations before opt-in screen shown |
| Network | dnsperf or pi-hole monitoring for unexpected DNS queries | No DNS queries to third-party analytics domains |
| System | auditd on Linux (Pi OS) for file opens | No read of user data directories by non-jarvis processes |
| App | MobSF or Frida on Android APK | No third-party SDK initialization before consent |
| App | Charles Proxy or Proxyman on iOS | No HTTPS connections to non-allowlisted domains |
| Cloud | AWS VPC flow logs or GCP network logs | No data leaves designated VPC; no unexpected cross-region traffic |
| Code | Dependency audit (npm audit, pip audit) | No SDK with known exfiltration behavior (e.g., certain crash reporters) |

### Privacy Test Scenarios

| Test | Method | Pass Criterion |
|---|---|---|
| Fresh install sends nothing | Full packet capture on hub during first boot + onboarding; analyzed for destination IPs | 0 bytes to non-local destinations before user opts in |
| Telemetry toggle off = no telemetry | Enable all features; disable telemetry in settings; run hub for 72h; capture all outbound traffic | 0 bytes sent to analytics/telemetry endpoints |
| Voice data not retained | Speak 50 commands; dump hub filesystem (grep for wav/mp3/opus); examine STT pipeline memory | 0 audio files stored; 0 audio segments in memory >30s |
| Cloud sync is truly opt-in | Fresh install; network monitor; complete all onboarding WITHOUT cloud sync toggle; verify no cloud contact | 0 DNS queries to cloud sync infrastructure |
| Data export is complete | Request data export; compare export against hub database dump | Export matches DB within field-level accuracy |
| Data deletion is complete | Delete all data; perform forensic disk image; search for residual PII | 0 residual PII bytes in hub storage |
| Child account has zero pattern access | As child account, attempt to read all patterns; attempt to read device history | All reads return empty or access-denied |

### Privacy Regression Testing

Every CI run must include:
- A network capture test that runs a fresh hub install and verifies 0 outbound bytes before opt-in
- A DNS query test that runs the full telemetry stack and verifies 0 queries to analytics domains

---

## Matter Protocol Testing Approach

Matter is the protocol layer that makes JARVIS work with devices from multiple brands. Testing it requires both protocol-level correctness and end-to-end functional validation.

### Matter Testing Layers

| Layer | What | Tool/Method |
|---|---|---|
| Protocol compliance | Does JARVIS correctly implement Matter spec (cluster commands, attributes, subscriptions)? | Matter Test Harness (CSA certified); Bluetooth sniffer for commissioning flow |
| Device pairing | Can JARVIS successfully commission and pair with certified Matter devices? | Test with IKEA, Nanoleaf, TP-Link reference devices |
| Command correctness | Do on/off, dim, color, temperature commands execute correctly on each device type? | Automated end-to-end: send command → verify device state change |
| Command latency | How long from hub command to device confirmation on LAN? | LAN-based performance test; target <200ms |
| Error handling | What happens when a Matter device goes offline mid-command? | Inject device offline; verify graceful error handling + user notification |
| Concurrent commands | Can JARVIS handle 10 devices receiving commands simultaneously? | Concurrency test; verify no race conditions or fabric corruption |
| Thread/BLE boundary | Matter supports Thread and BLE commissioning. Does JARVIS correctly handle both? | Test one device via Thread border router, one via BLE commissioning |
| Firmware updates | Matter OTA update process — does JARVIS correctly push firmware to devices? | OTA test with a firmware-updatable device (e.g., smart plug) |
| Stress | Long-running Matter fabric with 20+ devices — does performance degrade? | 72-hour fabric stress test |

### Matter Device Certification

v0.1 ships with support for 3 certified Matter devices minimum. Before declaring device compatibility, we must verify:

- [ ] Device pairs with JARVIS hub in < 60 seconds
- [ ] All standard clusters (on/off, level, color, temperature) work correctly
- [ ] Device remains in fabric after hub reboot
- [ ] Device is controllable via voice command end-to-end
- [ ] Device state is reflected correctly in mobile app
- [ ] Device removal (unpair) works cleanly and removes all associated data

---

## Mobile App Testing (Flutter)

The JARVIS mobile app is built in Flutter for iOS and Android. Testing strategy:

### Device and OS Coverage

v0.1 minimum supported versions: **iOS 15+**, **Android 11+**

| Tier | Devices | Why |
|---|---|---|
| Primary | iPhone 12, 13, 14 (various sizes) | Most common iOS devices in target demographic |
| Primary | Google Pixel 5, 6, 7 | Clean Android reference; good proxy for mainstream Android |
| Secondary | Samsung Galaxy S21, S22 | Largest Android OEM; One UI behavioral differences |
| Secondary | iPad (iOS 15+) | App should work on tablet; must verify layout |
| Tertiary | Low-end Android (Moto G Power, Galaxy A32) | Entry-level Android; verify performance acceptable |
| Tertiary | iPhone SE (2022) | Smallest iOS device; verify layout and performance |

### Flutter-Specific Testing Considerations

| Area | Tool | What We Test |
|---|---|---|
| Widget tests | flutter test | Individual widget rendering, state changes, user interactions |
| Integration tests | flutter test integration_test | Full user flows: onboarding, device control, notifications |
| Platform channels | Custom test harness | Hub ↔ app communication via platform channels; error handling |
| Background notifications | firebase_messaging + manual testing | Push notifications received and displayed when app is backgrounded |
| Deep links | App Links (Android) / Universal Links (iOS) | JARVIS deep links open correct screen; handle missing app gracefully |
| Offline behavior | Network link conditioner | App works correctly when hub is unreachable; shows appropriate offline state |
| Accessibility | Semantics + axe-core | All interactive elements accessible; screen reader compatible |
| Performance | flutter performance | UI renders at 60fps; no jank on mid-range devices |
| APK size | Build artifact analysis | APK < 50MB (excluding ML models); app bundle < 30MB |

### Mobile App Test Scenarios

| Test | Pass Criterion |
|---|---|
| Install from App Store / Play Store | Installs without error on iOS 15+ / Android 11+ |
| Hub discovery | App discovers hub on LAN within 10 seconds of being on same network |
| Device dashboard loads | All paired devices shown within 3 seconds of app open |
| Toggle device (on/off) | Tap in app → device state changes → confirmation shown within 300ms |
| Voice command via app | Press mic in app → speak command → command executes within 2s |
| Push notification received | Hub sends event → notification appears on phone within 5s |
| Notification opens app to correct screen | Tap notification → app opens to relevant device/room |
| App works offline (hub unreachable) | Disable network; app shows offline banner; does not crash |
| Re-authentication | Session expires; user re-authenticates; returns to same screen |
| Family member invite | Parent invites child; child accepts; child sees appropriate restrictions |
| Parental controls | Parent restricts child account; restriction enforced on hub |
| Delete account | User deletes account from app; all user data removed from hub and cloud |
| App update from store | Update app without losing hub pairing or device configurations |

---

## Test Environment Strategy

| Environment | Purpose | How It Is Provisioned |
|---|---|---|
| Dev | Individual developer testing | Local Docker Compose (hub + MQTT + Matter simulator) |
| CI | Automated gate checks on every commit | GitHub Actions; ephemeral VMs; Matter device simulators |
| QA | Manual testing, red team exercises | Dedicated Pi 4 cluster in office; physical Matter devices |
| Beta | 50 household field environment | Over-the-air update to beta hub image; real home environments |
| Staging | Pre-release validation | Simulated home with 20 Matter devices; automated weekly run |

### Matter Device Farm

A dedicated shelf of Matter-certified test devices for QA and CI:

| Device | Quantity | Purpose |
|---|---|---|
| IKEA TRÅDFRI bulb (E27) | 3 | Basic on/off + dimming |
| Nanoleaf Essentials bulb | 2 | Color + color temperature |
| TP-Link Tapo plug | 3 | On/off + power monitoring |
| Smart lock (e.g., Yale Assure) | 2 | Lock/unlock + audit log |
| Smart thermostat (e.g., Nest) | 1 | Temperature control + schedules |
| Motion sensor | 2 | Presence detection trigger |
| Contact sensor | 2 | Door/window state |

---

## Test Types and When They Run

| Test Type | Frequency | Environment |
|---|---|---|
| Unit tests (hub + app) | Every commit (CI) | GitHub Actions |
| Integration tests (hub + Matter) | Nightly | CI + physical device farm |
| Privacy regression tests | Every commit (CI) | CI with network capture |
| Voice accuracy tests | Weekly | QA lab with microphone array |
| Red team exercises | Pre-release (S-04 through S-07) | QA + external red teamer |
| Performance benchmarks | Weekly | Pi 4 dedicated bench |
| Beta household validation | Continuous | 50 real households |

---

## Quality Metrics for v0.1

| Metric | Definition | Target |
|---|---|---|
| Defect escape rate | % of known bugs that escape to beta households | < 5% |
| Mean time to detect (MTTD) | Average time from bug introduction to bug detection | < 7 days |
| Mean time to resolve (MTTR) | Average time from bug detection to fix deployed | < 14 days |
| Test coverage (functional) | % of code paths exercised by automated tests | > 80% |
| Test coverage (safety-critical) | % of safety-critical code paths exercised | > 95% |
| Voice intent accuracy | % of voice commands correctly understood and executed | > 90% |
| Device pairing success | % of pairing attempts that succeed | > 85% |
| Beta NPS | Net Promoter Score from beta households | > 30 |

---

*Next: See [RED-TEAM.md](./RED-TEAM.md) for our structured red team exercise plan.*