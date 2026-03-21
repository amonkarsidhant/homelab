# Homelab Backup System

## Architecture

```
Azure VM (Homelab)
  │
  ├──[1] GitHub Mirror ──────────────────────► github.com/amonkarsidhant/homelab (PRIVATE)
  │       (automatic on every push)
  │
  ├──[2] Encrypted Tarball ──────────────────► ~/backups/homelab-backup-YYYYMMDD.tar.gz.gpg
  │       (daily via overnight agent)
  │
  └──[3] Tailscale VPN ─────────────────────► Raspberry Pi (LAN backup, 24/7)
       │
       └──[4] rsync ────────────────────────► MacBook (secondary LAN backup)
```

## What's Backed Up

| Category | Contents | Encrypted |
|----------|----------|-----------|
| Homelab git | All compose files, scripts, docs, terraform, ansible | No |
| Traefik | docker-compose.yml, traefik.yml, dynamic configs | No |
| Observability | prometheus.yml, alertmanager.yml, docker-compose | No |
| Other services | Gitea, Act Runner, Goalert, Backstage, n8n, Authelia, Vaultwarden | No |
| Home configs | .bashrc, .ssh/config, .gitconfig, opencode.json | No |
| Docker state | Volume list snapshot | No |
| Secrets | vaultwarden_data, authelia_config (Docker volumes) | **Yes (GPG)** |

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/backup/backup-runner.sh` | Main backup orchestrator |
| `scripts/backup/restore.sh` | Decrypt and restore from archive |
| `scripts/backup/install-tailscale.sh` | VPN setup for Pi/Mac access |
| `scripts/autonomous/agents/backup-agent.sh` | Overnight agent wrapper |

## Quick Start

### 1. Set a GPG passphrase (recommended)

```bash
# Generate a strong passphrase
gpg --gen-random --armor 1 32 | tr -dc 'a-zA-Z0-9'

# Add to ~/.config/homelab/backup.env
echo 'BACKUP_PASSPHRASE="your-generated-passphrase"' >> ~/.config/homelab/backup.env
```

### 2. Run first backup manually

```bash
BACKUP_PASSPHRASE="your-passphrase" ~/homelab/scripts/backup/backup-runner.sh
```

### 3. Set up Tailscale for Pi/Mac access

```bash
~/homelab/scripts/backup/install-tailscale.sh
```

### 4. Configure Pi/Mac targets (after Tailscale)

Edit `~/.config/homelab/backup.env`:
```bash
DEST_PI_USER=pi
DEST_PI_PATH=/home/sidhant/backups

DEST_MAC_USER=sidhant
DEST_MAC_PATH=/Users/sidhant/backups
```

## Restore from Backup

```bash
BACKUP_PASSPHRASE="your-passphrase" \
  ~/homelab/scripts/backup/restore.sh \
  ~/backups/homelab-backup-20260320-120000.tar.gz.gpg
```

## Recovery Scenario

If the Azure VM is destroyed:

1. **Spin up new VM** (Ubuntu 22.04+)
2. **Clone from GitHub**:
   ```bash
   git clone https://github.com/amonkarsidhant/homelab.git ~/homelab
   cd homelab && git checkout feature/backup-system
   ```
3. **Install dependencies**: Docker, Docker Compose, Tailscale
4. **Restore configs**: Run backup restore from Pi or Mac tarball
5. **Spin up services**: `docker compose up -d` per service
6. **Restore secrets**: Decrypt vaultwarden/authelia volumes from encrypted backup
