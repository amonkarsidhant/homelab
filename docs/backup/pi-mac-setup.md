# Pi & Mac Backup Target Setup

## Raspberry Pi Setup

### 1. Install rsync daemon

```bash
sudo apt update && sudo apt install -y rsync

sudo mkdir -p /home/sidhant/backups
sudo chown -R $(whoami):$(whoami) /home/sidhant/backups
```

### 2. Configure rsync daemon (`/etc/rsyncd.conf`)

```
[homelab-backups]
  path = /home/sidhant/backups
  read only = false
  auth users = sidhant
  secrets file = /etc/rsyncd.secrets
  list = yes
```

### 3. Set up rsync credentials (`/etc/rsyncd.secrets`)

```bash
sudo bash -c 'echo "sidhant:rsync_password_here" | tee /etc/rsyncd.secrets'
sudo chmod 600 /etc/rsyncd.secrets
```

### 4. Enable and start rsyncd

```bash
sudo systemctl enable rsync
sudo systemctl start rsync
```

### 5. Open rsync port (if UFW is active)

```bash
sudo ufw allow 873/tcp
```

---

## MacBook Setup

### 1. Enable Remote Login

- System Settings → Sharing → Enable "Remote Login"
- Allow access for: "Only these users" → your user

### 2. Create backups directory

```bash
mkdir -p ~/backups
chmod 755 ~/backups
```

---

## Add SSH keys to Pi and Mac

From the Azure VM:

```bash
# Add Pi
ssh-copy-id sidhant@<pi-lan-ip>

# Add Mac
ssh-copy-id sidhant@<mac-lan-ip>
```

Test connections:
```bash
ssh sidhant@<pi-lan-ip> "echo Pi OK"
ssh sidhant@<mac-lan-ip> "echo Mac OK"
```

---

## Configure Tailscale (connects VM to LAN devices)

After installing Tailscale on all devices, add these to `~/.config/homelab/backup.env`:

```bash
DEST_PI="sidhant@$(tailscale -- tabular output ip -4):/home/sidhant/backups"
DEST_MAC="sidhant@$(tailscale -- tabular output ip -4):/Users/sidhant/backups"
```
