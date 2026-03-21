#!/usr/bin/env bash
set -euo pipefail

ARCHIVE="${1:-}"
if [ -z "$ARCHIVE" ]; then
  echo "Usage: $0 <backup.tar.gz.gpg>"
  echo ""
  echo "Decrypt and restore homelab from backup."
  echo "Example:"
  echo "  ./restore.sh ~/backups/homelab-backup-20260320-120000.tar.gz.gpg"
  exit 1
fi

PASSPHRASE="${BACKUP_PASSPHRASE:-}"
if [ -z "$PASSPHRASE" ]; then
  echo "Set BACKUP_PASSPHRASE env var first"
  exit 1
fi

TEMP=$(mktemp -d)
echo "$PASSPHRASE" | gpg --batch --yes --passphrase-fd 0 -o "$TEMP/backup.tar.gz" "$ARCHIVE"
tar -xzf "$TEMP/backup.tar.gz" -C "$TEMP"
echo "Backup contents:"
ls "$TEMP"
echo ""
echo "To restore configs, extract manually:"
echo "  tar -xzf $TEMP/backup.tar.gz -C /"
echo ""
echo "To restore a specific file:"
echo "  tar -xzf $TEMP/backup.tar.gz -O path/to/file > /restored/path/to/file"
rm -rf "$TEMP"
