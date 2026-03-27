# INTEGRATIONS.md — Integration Strategy

**Version:** 0.1  
**Author:** CTO (jarvis-cto)  
**Date:** 2026-03-27  

---

## Overview

JARVIS Home OS must integrate with three external ecosystems: **Home Assistant** (local automation backbone), **voice assistants** (Google Home, Alexa, Apple HomeKit), and **decor brands** (OEM white-label API). This document defines those integration boundaries, protocols, and the brand OEM API surface.

---

## Home Assistant Integration

### Strategic Position

Home Assistant is **not a competitor** — it is a force multiplier. JARVIS uses Home Assistant as the integration layer for non-Matter devices (Zigbee, Z-Wave, Tuya, Shelly). We do not re-implement what HA does well.

| Capability | JARVIS Owns | Home Assistant Owns |
|-----------|-------------|----------------------|
| Voice agent (wake word, STT, intent) | ✅ | ❌ |
| Matter fabric management | ✅ | Partial (Matter proxy) |
| Device control (Matter) | ✅ | ❌ |
| Device control (Zigbee, Z-Wave, Tuya) | Via HA API | ✅ |
| Automation engine | Own pattern learning | ✅ (YAML automations) |
| UI dashboard | Mobile app | HA dashboard (optional) |
| Energy history | Future Phase 2 | ✅ |

### Integration Architecture

```
JARVIS Hub
┌─────────────────────────────────────────────────────────┐
│  JARVIS Core (Rust)                                     │
│  ┌──────────┐ ┌──────────┐ ┌────────────────────────┐ │
│  │ Matter   │ │ Voice    │ │ Hub API Server         │ │
│  │ Stack    │ │ Runtime  │ │ (REST + WebSocket)     │ │
│  └────┬─────┘ └────┬─────┘ └───────────┬────────────┘ │
│       │            │                    │               │
│       └────────────┼────────────────────┘               │
│                    │                                    │
│  JARVIS Agent (Python)                                 │
│  ┌──────────────┐ │ ┌──────────────┐                    │
│  │ Intent       │ │ │ Pattern      │                    │
│  │ Handlers     │ │ │ Learning     │                    │
│  └──────┬───────┘ │ └──────────────┘                    │
│         │         │                                     │
│         └─────────┼─────────────────────────────────────┘
│                   │ WebSocket / REST
┌───────────────────┼─────────────────────────────────────┐
│  Home Assistant (Docker)                                │
│  ┌──────────────┐ │ ┌──────────────┐ ┌──────────────┐  │
│  │ HA Core      │◄┘ │ Zigbee2MQTT  │ │ Z-Wave JS   │  │
│  │              │   │              │ │              │  │
│  │ HA API       │   │ Tuya         │ │ Shelly       │  │
│  └──────────────┘   └──────────────┘ └──────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### HA API Communication

**WebSocket (primary — real-time state):**
```python
# Python agent connects to HA WebSocket API
# Subscribes to: state_changed events for all devices
# Parses: entity_id, new_state, old_state
# Translates: HA entity → JARVIS device model
```

**REST API (secondary — commands):**
```
POST /api/services/switch/turn_on
POST /api/services/light/turn_on
  body: { "entity_id": "light.living_room" }
```

**Events (HA → JARVIS):**
| HA Event | JARVIS Action |
|----------|--------------|
| `state_changed` | Update device state in JARVIS SQLite, notify app |
| `automation_triggered` | Log to audit trail |
| `homeassistant_start` | Re-sync all device states |
| `homeassistant_stop` | Log event, continue Matter-only operation |

### Why Not Home Assistant Blue / HAOS?

| Factor | Home Assistant OS | Our Approach |
|--------|-------------------|--------------|
| Deployment | Bare-metal or VM | Docker on Pi OS |
| JARVIS integration | HA custom component | localhost API |
| Voice control | Native to HA (wyoming) | Our voice stack |
| Brand white-label | Not designed for | Core design goal |
| UX control | Limited | Full control |
| OTA updates | HA OS updates | Our update mechanism |

We value **UX control and brand white-label** — HAOS is too opinionated. Running HA Core in Docker gives us HA's device integrations without surrendering the JARVIS UX.

---

## Google Home Integration

### Are We a Google Home Action?

**No.** We do not build a Google Home Action in v0.1. Reasons:

1. **Privacy conflict:** A Google Home Action routes voice data through Google's cloud. This directly violates our "all inference runs locally" principle.
2. **Brand dilution:** If homeowners use "Hey Google" to control JARVIS, JARVIS becomes a backend — not the home intelligence platform. The brand relationship moves to Google.
3. **Technical dependency:** Google Actions require OAuth and account linking. This creates a mandatory cloud dependency for voice.

### Future (Phase 2+) — Google Home Mini as Secondary Wake Word

| Approach | Description |
|----------|-------------|
| **Local Assistant Bridge** | "Hey JARVIS" is primary. Google Mini is an optional secondary. Homeowner can say "Hey Google, ask JARVIS to..." — JARVIS handles intent, Google handles ASR. |
| **Matter Bridge (Google Home)** | JARVIS exposes devices to Google Home as a Matter controller. User can use Google Home app alongside JARVIS app. This is a Matter-native integration, not an Action. |

**Phase 2 approach:** Expose JARVIS-managed devices to Google Home via Matter. Google Home app can see and control JARVIS devices. User can say "Hey Google, turn off living room lights" — command goes to Matter hub (JARVIS), not Google Cloud.

---

## Alexa Integration

### Are We an Alexa Smart Home Skill?

**Same reasoning as Google Home — No for v0.1.**

1. Alexa Smart Home Skills route through Amazon's cloud for intent parsing
2. Account linking (Amazon Login) creates mandatory cloud dependency
3. Brand relationship shifts to Amazon

### Future (Phase 2+)
- **Matter exposure:** Same as Google Home — JARVIS is a Matter hub, exposes devices via Matter to Alexa
- **Alexa as optional wake word:** Alexa Echo devices can act as optional secondary microphone, routing to JARVIS local inference via LAN

---

## Apple HomeKit

### HomeKit Integration

**Why HomeKit is different:**
- HomeKit has a **local API** (HomeKit Accessory Protocol) that works over LAN without cloud
- Apple Home app can pair with Matter devices directly (Matter over Thread/WiFi)
- HomeKit is Matter-certified — Matter devices appear in Apple Home app natively

**Our approach:**
- JARVIS does NOT implement HomeKit Accessory Protocol (HAP) — that's Apple's certification burden
- Matter devices managed by JARVIS appear in Apple Home via Matter (no separate pairing needed)
- User uses Apple Home app OR JARVIS app — their choice
- HomePod can serve as optional Siri voice input for Matter devices

**No Siri integration in v0.1.** Siri Shortcuts could be a Phase 2 integration point.

---

## Brand OEM API

### Overview

Decor brands (IKEA, Wayfair, Ashley) white-label JARVIS as "their" smart home brain. The brand OEM API allows:

1. Brand app to connect to JARVIS hub and control branded devices
2. Brand to customize JARVIS voice name, wake word, personality
3. Brand to receive opt-in telemetry for dashboard and analytics
4. Brand to push skill updates to their deployed base

### Brand OEM SDK

**Delivered as:** Flutter plugin + REST API bindings
**Purpose:** Allows brand to embed JARVIS control in their existing app

```dart
// Brand app initialization
final jarvis = JarvisOEM(
  hubId: 'BRICK-XXXX',       // Brand-prefixed hub ID
  brandId: 'ikea',            // Brand identifier
  apiKey: 'brand_xxx',        // Per-brand API key (JARVIS Cloud issues)
  oemEndpoint: 'ikea.jarvis.cloud', // Brand's JARVIS Cloud tenant
);

// Connect to household hub
await jarvis.connect(
  householdId: 'hh_abc123',
  oemToken: 'tok_xxx',        // OAuth token from brand's identity
);

// Issue commands
await jarvis.devices.setState(
  deviceId: 'matter_001',
  state: { 'on_off': true, 'brightness': 80 },
);

// Receive events
jarvis.devices.events.listen((event) {
  // { deviceId, state, timestamp }
});
```

### OEM API Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/oem/v1/hub/discover` | POST | Find hubs for household (mDNS via brand cloud relay) |
| `/oem/v1/hub/{id}/pair` | POST | OAuth-based hub pairing (brand token → household access) |
| `/oem/v1/devices` | GET | List all devices visible to brand |
| `/oem/v1/devices/{id}/control` | POST | Send command to device |
| `/oem/v1/events/stream` | WS | Real-time device event stream |
| `/oem/v1/telemetry` | POST | Opt-in telemetry from hub to brand |
| `/oem/v1/skills/push` | POST | Push skill updates to hub (brand-controlled skills) |

### Brand Customization Points

| Customization | Scope | Implementation |
|--------------|-------|----------------|
| Voice name | "Hey IKEA" vs "Hey JARVIS" | Wake word model swap + TTS voice model |
| App theme | Brand colors, logo, typography | Flutter theme injection at runtime |
| Device icons | Brand-specific icon set | Icon pack override |
| Welcome flow | Brand onboarding UX | App screens/branding |
| Skill set | Brand-specific skills only | Skill manifest filtered by brand |
| Skill store | Brand's curated skill store | OEM-branded skill marketplace |

### Telemetry (Opt-In Only)

Brand OEM telemetry is **strictly opt-in** — disclosed during hub setup, user can revoke at any time.

| Data | Granularity | Purpose |
|------|-------------|---------|
| Device type | Category only (bulb, plug, sensor) | Product analytics |
| Usage frequency | Daily aggregates | DAU/MAU metrics |
| Skill usage | Per-skill activation count | Skill effectiveness |
| Hub health | Online/offline/updating | Support automation |
| **NOT collected** | Voice transcripts, device state values, household identity | Privacy |

---

## Integration Summary Matrix

| Integration | v0.1 | Phase 2 | Phase 3 |
|------------|------|---------|---------|
| Home Assistant (Zigbee, Z-Wave, Tuya) | ✅ Docker container | ✅ HA 2024+ | ✅ Full HA ecosystem |
| Google Home (Matter exposure) | ❌ | ✅ Matter bridge | ✅ Google Actions (opt-in) |
| Alexa (Matter exposure) | ❌ | ✅ Matter bridge | ✅ Alexa Skills (opt-in) |
| Apple HomeKit (Matter) | ✅ Matter native | ✅ | ✅ |
| Apple Siri Shortcuts | ❌ | ✅ | ❌ |
| Brand OEM SDK | ❌ | ✅ Alpha | ✅ GA |
| Brand telemetry API | ❌ | ✅ Alpha | ✅ |
| IFTTT | ❌ | ❌ | ✅ |

---

## Third-Party Skill Ecosystem (Phase 3)

**Phase 3 only — not in scope for v0.1 or Phase 2.**

Skills extend JARVIS capabilities (e.g., "order more paper towels when low", "report energy usage to utility"). Skills are:
- Distributed via JARVIS Skill Store (brand-curated or JARVIS-curated)
- Sandboxed Python subprocesses with permission system
- Reviewed by JARVIS CQO team before listing
- Can be disabled by homeowner at any time

**Skill permissions model:**
```
skills/
├── manifest.json         # skill metadata, permissions requested
├── skill.py             # skill logic (Python)
├── requirements.txt     # pip packages (reviewed by CQO)
└── icon.png             # skill icon

manifest.json:
{
  "name": "Paper Towel Reminder",
  "version": "1.0.0",
  "permissions": [
    "device:read:printer",
    "order:write:amazon",
    "notification:send"
  ],
  "sandbox": "python_subprocess"
}
```

---

## Consequences

### Positive
- Home Assistant integration gives instant device ecosystem without re-implementation
- Matter-native integrations with Google/Alexa/Apple require no Action/Skill development
- Brand OEM API enables B2B revenue without competing with Home Assistant ecosystem
- Phase 2 Matter bridge approach keeps privacy promise (local inference, not cloud ASR)

### Negative
- HA Docker container adds ~2GB image size and RAM overhead
- Two update mechanisms (JARVIS + HA) require coordination
- Google/Alexa integration deferred to Phase 2 delays voice assistant diversity

### Risks
- **Mitigation:** HA Docker image is pinned to a known-good hash — tested updates before rollout
- **Risk:** Brand OEM API changes break brand apps — mitigated by semantic versioning and deprecation windows

---

## References

- [ADR-001 — Local-First Agent Runtime](./ADR-001.md)
- [ADR-002 — Matter Bridge Strategy](./ADR-002.md)
- [ADR-003 — Mobile App Stack](./ADR-003.md)
- [Technology Stack STACK.md](./STACK.md)
- [Self-Hosting Deployment DEPLOYMENT.md](./DEPLOYMENT.md)
- PRD v0.1 — Section 3 (Core Features for v0.1)
