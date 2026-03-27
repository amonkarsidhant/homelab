# DEPLOYMENT.md — Self-Hosting Deployment Model

**Version:** 0.1  
**Author:** CTO (nestra-cto)  
**Date:** 2026-03-27  

---

## Overview

Nestra Home OS is designed for **self-hosted deployment** — a non-technical homeowner should be able to flash an SD card and have a working system within 30 minutes. This document defines the deployment model, Day 1 ship artifact, onboarding UX, update mechanism, and minimum hardware requirements.

**Core constraint:** The homeowner owns the hardware. We cannot require cloud infrastructure for Day 1 operation.

---

## Day 1 Ship Artifact

### What Ships

**Nestra Hub Image — Raspberry Pi Imager compatible**

We ship a **pre-configured Raspberry Pi OS image** (`.img` file) that homeowners flash using the [Raspberry Pi Imager](https://www.raspberrypi.com/software/) app.

**Image contents:**
```
nestra-hub-img/
├── raspberrypi-os.img (32GB, sparse, expandable on first boot)
├── bootsector/
│   ├── config.txt (overlays, WiFi country, GPU memory)
│   ├── cmdline.txt (root=PARTUUID, initramfs)
│   └── userconf.txt (ssh enabled by default)
├── rootfs/
│   ├── etc/
│   │   ├── docker/daemon.json (storage driver, log rotation)
│   │   ├── systemd/system/docker-compose@nestra.service
│   │   └── NetworkManager/conf.d/ (static IP fallback)
│   ├── var/lib/nestra/
│   │   ├── household.db (empty, created on first boot)
│   │   ├── models/ (Whisper + LLM model dirs, empty on image)
│   │   └── certs/ (self-signed TLS cert generated on first boot)
│   ├── usr/local/bin/
│   │   ├── nestra-setup (first-boot wizard CLI)
│   │   └── nestra-update (update script)
│   └── docker/
│       ├── nestra-core.tar (preloaded, loaded on first boot)
│       └── homeassistant.tar (preloaded, loaded on first boot)
└── partitions/
    ├── boot (FAT32, ~1GB)
    └── root (ext4, ~30GB, expandable)
```

**Image size:** ~4GB compressed, expands to 32GB on first boot.

**Download:** Hosted on Nestra Cloud (opt-in download) and IPFS (decentralized fallback).

---

## Installation Flow (Non-Technical Homeowner)

### Step 1: Download and Flash (10 minutes)
```
1. Homeowner downloads "Nestra Home OS" from nestra.homeos.io
2. Opens Raspberry Pi Imager
3. Selects "Nestra Home OS" custom image (discovers .img via API or manual download)
4. Configures WiFi SSID + password in Imager (advanced options)
5. Writes image to microSD card (32GB minimum)
6. Inserts microSD into Pi 4, powers on
```

### Step 2: First Boot Setup (10–15 minutes)
```
1. Pi boots, Nestra setup wizard runs automatically
2. User connects phone to Nestra WiFi ("Nestra-XXXX" hotspot)
3. User opens http://setup.nestra.local in browser
4. Setup wizard:
   a. Set household name + location (room count)
   b. Create first parent account (name + 6-digit PIN)
   c. Pair first Matter device (scan QR code)
   d. Download Nestra app from App Store / Play Store
   e. Scan QR code on Pi to link app to hub
5. Setup complete — "Hey Nestra" is now active
```

**Critical UX requirement:** No step requires typing an IP address, opening a terminal, or using command line.

### Step 3: Day 1 Feature Validation
After setup, the homeowner should be able to:
1. Say "Hey Nestra, turn on the living room lights" — lights turn on
2. Open the Nestra app — see device dashboard
3. Toggle a device manually in the app — device responds
4. Disconnect home router from internet — all above still work

---

## Raspberry Pi Imager Integration

**Goal:** Make Nestra appear as a first-class OS choice in Raspberry Pi Imager.

We will pursue official listing in Raspberry Pi Imager's custom OS picker. This requires:
- Submitting to [rpi-imager品鉴](https://github.com/raspberrypi/rpi-imager) as a custom OS
- Providing a metadata JSON endpoint for OS updates
- Maintaining a download server with checksums

**Interim:** Host image on nestra.homeos.io with manual download instructions.

---

## Hardware Requirements

### Minimum (v0.1 — Activatable)
| Component | Spec |
|-----------|------|
| Board | Raspberry Pi 4 (4GB) |
| Storage | 32GB microSD (Class A2 recommended) |
| Network | WiFi 802.11ac (2.4GHz + 5GHz) or Ethernet |
| Audio | USB microphone (any UAC-compatible) |
| Power | USB-C 5V/3A (official Pi 4 power supply) |
| Thread | 802.15.4 USB dongle (Nordic nRF52840) |

### Recommended (v1.0 — Full Experience)
| Component | Spec |
|-----------|------|
| Board | Raspberry Pi 5 (8GB) |
| Storage | 64GB microSD (A2) + 128GB USB SSD (boot from USB) |
| Network | Ethernet (primary) + WiFi (backup) |
| Audio | ReSpeaker 4-mic array (far-field voice) |
| Thread | Built-in (via future Pi 5 802.15.4 hat) |
| Power | Official Pi 5 power supply (27W USB-C PD) |

### Unsupported (Will Not Work)
- Raspberry Pi Zero (no USB audio, insufficient RAM)
- Raspberry Pi 3 (marginal CPU, no 802.11ac)
- Any x86 thin client (not ARM — future roadmap item)

---

## Update Mechanism

### Goals
- Updates must not break the home (no failed updates leaving system in broken state)
- Homeowner should not need to do anything (auto-update with maintenance window)
- Critical security updates deploy immediately (bypass maintenance window)

### Update Architecture

```
┌─────────────────┐         ┌─────────────────┐         ┌─────────────────┐
│  Nestra Cloud   │◄────────│   GitHub Releases│         │  IPFS (mirror)  │
│  (update meta)  │         │  (binary host)  │         │                 │
└────────┬────────┘         └────────┬────────┘         └────────┬────────┘
         │                            │                            │
         │ check: GET /api/v1/updates │                            │
         │ ◄─── { version, hash, url }│                            │
         │                            │                            │
         │ download: GET /updates/vX.Y │                            │
         │ ◄─── docker-compose.yml + image.tar                      │
         │                            │                            │
         │                            │                            │
         ▼                            ▼                            ▼
┌─────────────────────────────────────────────────────────────────────────┐
│  Nestra Hub (Raspberry Pi)                                             │
│                                                                         │
│  Update process (runs at 3 AM by default, configurable):               │
│  1. Download new image.tar to /tmp/nestra-update/                       │
│  2. Verify SHA-256 hash against metadata                                │
│  3. docker load -i image.tar (load new image side-by-side old)          │
│  4. docker compose down (stop old containers)                           │
│  5. docker compose up -d (start new containers)                        │
│  6. Health check: GET /api/v1/hub/status returns 200                   │
│  7. If health check passes: delete old Docker image                     │
│  8. If health check fails: rollback (docker tag old image back, restart)│
└─────────────────────────────────────────────────────────────────────────┘
```

### Rollback Strategy
- Docker images are tagged with semantic version (`nestra-core:v0.1.0`, `nestra-core:v0.1.1`)
- Before update, current image is tagged as `nestra-core:previous`
- Failed health check → `docker tag nestra-core:previous nestra-core:latest && docker restart nestra-core`
- Rollback completes in <30 seconds

### Maintenance Window
- Default: 3:00 AM local time (configurable)
- Updates only apply when no one is home (motion sensors confirm no activity for 30 min)
- If motion detected during update, update is postponed to next window
- **Critical security updates (CQO-declared):** Skip maintenance window, deploy immediately

### Update Communication
- App notification: "Nestra will update tonight at 3 AM. Tap to reschedule."
- Post-update notification: "Nestra updated to v0.1.1. Tap to see what's new."

---

## Home Assistant OS Deployment

Home Assistant OS (HAOS) is deployed as a separate Docker container using the official `ghcr.io/home-assistant/home-assistant:stable` image.

### Why Not Home Assistant OS (hassos)?
- HAOS is a full embedded OS (runs bare-metal, not containerized)
- Running HAOS alongside Nestra on Pi would require dual-booting or VM
- **Our approach:** Run HA Core inside Docker on Pi OS — same functionality, simpler deployment
- HA runs as `homeassistant` container; Nestra communicates via localhost API

### HAOS Update Strategy
- HA container updates independently from Nestra core
- HA follows its own release cycle (bi-weekly)
- HA updates are applied in the same maintenance window
- Nestra tests HA update compatibility before shipping Nestra updates

---

## Container Management

### Single-Container v0.1
```
Dockerfile:
  FROM python:3.11-slim + rust (multi-stage)
  - Nestra core (Rust) compiled to single binary
  - Python agent loaded as embedded interpreter (PyO3)
  - SQLite baked into image
  - Entrypoint: /usr/local/bin/nestra-core
```

### Multi-Container v1.0
```
docker-compose.yml:
  services:
    nestra-core:
      image: nestra/core:${VERSION}
      volumes:
        - household-db:/var/lib/nestra/
        - models:/usr/local/share/nestra/models/
        - certs:/var/lib/nestra/certs/
      ports:
        - "8443:8443"
      restart: unless-stopped

    homeassistant:
      image: ghcr.io/home-assistant/home-assistant:stable
      volumes:
        - ha-config:/config
        - /run/dbus:/run/dbus:ro
      network_mode: host
      restart: unless-stopped
      privileged: true

    nestra-mqtt:
      image: eclipse-mosquitto:2
      volumes:
        - mqtt-data:/mosquitto/data
        - mqtt-log:/mosquitto/log
      ports:
        - "1883:1883"
      restart: unless-stopped

  volumes:
    household-db:
    models:
    certs:
    ha-config:
    mqtt-data:
    mqtt-log:
```

---

## Remote Access (Home+ Optional Feature)

When user enables Home+ remote access:

1. Hub establishes outbound WebSocket to `wss://relay.nestra.cloud`
2. Connection persists (Cloudflare Durable Object maintains mapping)
3. App connects to same relay URL
4. Relay forwards WebSocket frames bidirectionally
5. All traffic is end-to-end encrypted (Noise Protocol)

**No inbound ports opened on home router. No NAT traversal required.**

---

## Security Considerations

### First Boot Certificate Generation
- Self-signed TLS certificate generated on first boot
- Certificate Common Name = `nestra-<hub-id>.local`
- SHA-256 fingerprint displayed in app during pairing
- Homeowner visually verifies fingerprint before approving hub pairing

### Zero-Trusted Network
- Hub rejects all commands from devices not in household registry
- MQTT broker (v1.0) requires username/password (generated on first boot)
- App authentication: 6-digit PIN (Argon2 hashed on hub)
- No default passwords on any service

### Fail-Safe
- If Docker fails to start on boot, system drops to emergency AP mode
- Emergency AP: "Nestra-Setup" WiFi with captive portal for factory reset
- Factory reset: re-flash SD card (no OTA factory reset — physical access required)

---

## Consequences

### Positive
- Non-technical homeowner can set up in <30 minutes
- Single SD card flash is the entire deployment artifact
- Auto-updates with rollback protect against broken updates
- Offline-first: no internet required for any P0 feature

### Negative
- Image size (~4GB compressed) requires good download speed (10+ Mbps recommended)
- Raspberry Pi Imager listing requires application and approval process
- HA container adds ~1GB RAM overhead on top of Nestra

### Risks
- **Mitigation:** Provide fallback download via IPFS for regions with Cloudflare censorship
- **Risk:** Pi 4 supply chain — mitigated by supporting Pi 5 as primary SKU

---

## References

- [ADR-001 — Local-First Agent Runtime](./ADR-001.md)
- [ADR-002 — Matter Bridge Strategy](./ADR-002.md)
- [Technology Stack STACK.md](./STACK.md)
- [Integration Strategy INTEGRATIONS.md](./INTEGRATIONS.md)
- PRD v0.1 — Section 3 (Core Features for v0.1)
