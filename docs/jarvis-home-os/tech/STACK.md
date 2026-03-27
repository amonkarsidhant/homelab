# STACK.md — Technology Stack Overview

**Version:** 0.1  
**Author:** CTO (jarvis-cto)  
**Date:** 2026-03-27  

---

## Guiding Principles

1. **Local-first:** All P0 features run on the hub without internet
2. **Offline-capable:** The home works when the internet is down
3. **Self-hosted:** Runs on hardware the homeowner owns and controls
4. **Privacy by architecture:** Cloud is opt-in, not mandatory

---

## Language Choices

### Rust — Performance-Critical Components

**Where Rust is used:**
- Matter protocol stack (fabric management, commissioning, cluster handling)
- Device communication daemon (handles all Matter, Zigbee via HA, Z-Wave via HA)
- Wake word engine (performance-critical DSP)
- Voice STT post-processing
- State management core (device registry, room topology)
- API server (HTTPS, WebSocket)
- Audit log writer (append-only, high-throughput)

**Why Rust:**
- Memory safety without GC — determinism required for real-time device control
- Zero-cost abstractions — performance equivalent to C for hot paths
- Thread safety — concurrent device state updates without data races
- Matter SDK reference implementations (connectedhomeip) are C++; Rust interops cleanly
- Single compiled binary — no runtime dependencies to break on update

**Rust Toolchain:**
```
Edition: 2021
ABI: stable
Min Rust version: 1.75 (for async traits)
Key crates: tokio (async runtime), rusqlite (SQLite), matter (SDK bindings), axum (HTTP)
```

### Python — Agent Logic

**Where Python is used:**
- Intent handlers (natural language → structured action)
- Pattern learning engine (frequency counting, time-series analysis)
- Guardrail evaluation logic
- Home Assistant API client
- Skill system (extensibility for future skills)
- OTA update orchestration

**Why Python:**
- Rapid iteration on ML features (pattern learning, intent classification)
- Python LLM ecosystems (llama.cpp bindings, sentence transformers) are mature
- Agentic AI patterns are easier to express in Python than Rust
- Python developer availability is higher than Rust for AI/ML features

**Why NOT Python for everything:**
- No memory safety — a Python crash takes down the agent, not the hub
- GC pauses cause unpredictable latency spikes
- Python for device control (Matter, Thread) would add unacceptable latency

**Python Toolchain:**
```
Version: 3.11+
Virtual env: venv (no Poetry/Pipenv — reduces container image complexity)
Key packages: llama-cpp-python, sentence-transformers, homeassistant-api-client
```

### IPC: Rust ↔ Python
```
┌─────────────────┐    Unix Domain Socket    ┌─────────────────┐
│  JARVIS Core    │ ◄───── JSON RPC ────────► │  JARVIS Agent   │
│  (Rust daemon)  │                           │  (Python)       │
│  - Matter       │                           │  - Intent       │
│  - Device state │                           │  - Patterns     │
│  - API server   │                           │  - Guardrails   │
└─────────────────┘                           └─────────────────┘
```

---

## Home Hub — Embedded / Raspberry Pi

### Hardware Minimum
| Component | Minimum (v0.1) | Recommended (v1.0) |
|-----------|---------------|-------------------|
| CPU | Raspberry Pi 4 (4GB) | Raspberry Pi 5 (8GB) |
| Storage | 32GB microSD | 64GB microSD + USB SSD |
| Network | WiFi 802.11ac | Ethernet + WiFi |
| Thread | 802.15.4 USB dongle | Built-in (future SKU) |
| Audio | USB microphone + 3.5mm jack | ReSpeaker 4-mic array |

### OS: Raspberry Pi OS (Bookworm) vs DietPi vs Ubuntu Server

| OS | Pros | Cons |
|----|------|------|
| Raspberry Pi OS (Bookworm) | Best hardware support, broad community, 64-bit | Slightly bloated for embedded |
| DietPi | Minimal image, good Docker support, ~2GB | Smaller community |
| Ubuntu Server 24.04 | Excellent upstream support, Long term support | Heavier, 4GB+ base image |

**Decision: Raspberry Pi OS 64-bit (Bookworm)**
- Most hardware support (WiFi, Bluetooth, USB, GPIO)
- Widest community for troubleshooting
- Python 3.11+ available via apt
- We ship as a Docker image regardless — OS choice is for the base layer

### Docker on Pi
- **Why Docker:** JARVIS ships as a Docker image that runs on Pi OS. This ensures consistent environment and clean updates.
- **Runtime:** Docker Engine (not Podman — better ARM support, larger community)
- **Compose:** Docker Compose for local development, not for production deployment (single container for v0.1)
- **Container manager:** We do NOT use Kubernetes on the Pi — too heavy

### Single Container vs Multi-Container

**v0.1 (single container):**
```
┌─────────────────────────────────────┐
│ JARVIS Hub Container                │
│ ┌─────────────────────────────────┐ │
│ │ Python 3.11 (agent logic)       │ │
│ │ Rust (Matter + API + voice)     │ │
│ │ SQLite (household state)        │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
         ▲
         │ (bind mount)
┌─────────────────────────────────────┐
│ Home Assistant OS (separate Docker) │
└─────────────────────────────────────┘
```

**v1.0 (multi-container via Docker Compose):**
- `jarvis-core`: Rust Matter + voice
- `jarvis-agent`: Python intent + patterns
- `jarvis-ha`: Home Assistant OS (official image)
- `jarvis-mqtt`: Mosquitto (for HA ↔ JARVIS events)

---

## Cloud Components (Opt-In)

### When Cloud is Required
- Remote access when homeowner is away (Home+ tier)
- Cross-device learning sync (future Phase 2)
- OTA firmware update delivery
- Brand white-label telemetry (opt-in per brand agreement)

### Cloud Architecture: Serverless vs Containers

| Option | Decision | Rationale |
|--------|----------|-----------|
| AWS ECS/Fargate | Rejected | Over-engineered for relay service |
| AWS Lambda | Rejected | Cold starts break WebSocket relay |
| Cloudflare Workers | **Selected** | Edge compute, WebSocket support, global PoPs, Workers AI for future inference |
| Self-hosted (VPS) | Alternative for Home+ power users | Same Docker image, runs on any VPS |

**JARVIS Cloud = Cloudflare Workers + Durable Objects**
- WebSocket relay lives in Durable Objects — persistent connection state without Redis
- Workers handle TLS termination and routing
- Workers AI for future cloud inference (opt-in, not default)

**Cloud Infrastructure Cost (estimated, 50 beta households)**
```
Cloudflare Workers (relay): ~$0/month (within free tier)
Cloudflare Durable Objects: ~$5/month (50 households × $0.10/DO)
R2 for firmware images: ~$1/month (1GB)
Total: ~$6/month for 50 households → $0.12/household/month
```

---

## Database Choices

### Household State — SQLite

**Why SQLite (not PostgreSQL, not Redis):**
- SQLite is a single file — no daemon to manage on Pi
- WAL mode supports concurrent reads from Rust + Python
- sub-1ms reads for device state lookups
- Zero-configuration, zero administration
- Single file backup (cp /var/lib/jarvis/household.db)
- No network port exposed

**Schema (key tables):**
```sql
-- Device registry
CREATE TABLE devices (
  matter_id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  room_id TEXT,
  type TEXT NOT NULL,
  capabilities TEXT NOT NULL, -- JSON array of Matter clusters
  state TEXT NOT NULL,        -- JSON { "on_off": true, "brightness": 80 }
  last_seen INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

-- Room topology
CREATE TABLE rooms (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  floor INTEGER,
  icon TEXT
);

-- Household members
CREATE TABLE members (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('parent', 'child', 'guest')),
  pin_hash TEXT NOT NULL, -- Argon2
  created_at INTEGER NOT NULL
);

-- Learned patterns
CREATE TABLE patterns (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('time', 'motion', 'sequence')),
  trigger JSON NOT NULL,
  actions JSON NOT NULL,
  confidence REAL NOT NULL,
  enabled INTEGER NOT NULL DEFAULT 1,
  created_at INTEGER NOT NULL
);

-- Audit log (append-only)
CREATE TABLE audit_log (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  timestamp INTEGER NOT NULL,
  member_id TEXT,
  intent JSON NOT NULL,
  result TEXT NOT NULL CHECK (result IN ('allowed', 'blocked', 'modified')),
  reason TEXT,
  execution_time_ms INTEGER
);
```

**Performance:**
- 10,000 device state updates/day × 30 days = 300k rows — SQLite handles this
- Index on `timestamp` for time-range queries
- Index on `room_id` for room-scoped queries

**Backup:**
- Nightly cron: `cp household.db household.db.backup`
- Retain 7 backups (rolling window)
- Backup to USB drive if mounted (optional local storage tier)

### Pattern Learning — SQLite (same database)
- Patterns table (see above)
- Time-series events for pattern mining
- No separate time-series DB needed at v0.1 scale

### Cloud Sync (Future Phase 2) — PostgreSQL
- User accounts (Home+ tier)
- Encrypted household state snapshots (E2E encrypted, JARVIS Cloud cannot read)
- Brand white-label analytics (opt-in, aggregated, no PII)

---

## Key Libraries

| Layer | Library | Language | Purpose |
|-------|---------|----------|---------|
| Matter | connectedhomeip | C++ | Matter SDK (via Rust bindings via cxx or cpp_bindgen) |
| Matter (alt) | libpyrite | Rust | Pure Rust Matter implementation |
| Voice STT | whisper.cpp | C++ | Local speech-to-text |
| LLM Inference | llama.cpp | C++ | Local LLM inference |
| HTTP Server | axum | Rust | REST API server |
| WebSocket | tokio-tungstenite | Rust | Real-time events |
| SQLite | rusqlite | Rust | Device state, patterns |
| HA Client | homeassistant-api | Python | HA WebSocket/REST client |
| FFI | cxx | Rust | Safe Rust ↔ C++ interop |

---

## Development Toolchain

| Tool | Purpose |
|------|---------|
| `cargo` | Rust build + test |
| `uv` | Python package management (fast, Rust-based) |
| `just` | Command runner (replacement for Makefile) |
| `docker` | Local dev container |
| `docker compose` | Multi-container local dev |
| `flutter` | Mobile app build |
| `flutter_test` | Unit + widget tests |
| `mockito` | Dart mocking for tests |

---

## Summary

```
JARVIS Hub (Raspberry Pi 4/5)
├── Raspberry Pi OS 64-bit (Bookworm)
│
├── Docker Engine
│   ├── jarvis-core (Rust: Matter, voice, API, device state)
│   │   └── SQLite (household.db — device registry, patterns, audit)
│   │
│   └── homeassistant (Home Assistant OS — official image)
│       ├── Zigbee2MQTT
│       ├── Z-Wave JS UI
│       └── (other HA integrations)
│
├── Python 3.11 (agent logic)
│   └── llma.cpp bindings (local LLM inference)
│
├── whisper.cpp (voice STT)
│
└── OpenThread daemon (Thread Border Router)

JARVIS Cloud (Optional, Home+)
├── Cloudflare Workers (relay + routing)
└── Cloudflare Durable Objects (connection state)
```

---

## References

- [ADR-001 — Local-First Agent Runtime](./ADR-001.md)
- [ADR-002 — Matter Bridge Strategy](./ADR-002.md)
- [ADR-003 — Mobile App Stack](./ADR-003.md)
- [DEPLOYMENT.md — Self-Hosting Deployment](./DEPLOYMENT.md)
- [INTEGRATIONS.md — Integration Strategy](./INTEGRATIONS.md)
