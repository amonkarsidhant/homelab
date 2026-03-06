#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="${REPO_DIR:-/home/sidhant/homelab}"
REPORT_DIR="${REPORT_DIR:-$REPO_DIR/docs/chaos-reports}"
LOG_FILE="${CHAOS_LOG_FILE:-/home/sidhant/logs/chaos/events.log}"
TARGET_SERVICE="${TARGET_SERVICE:-jaeger}"
DURATION_SECONDS="${DURATION_SECONDS:-12}"

mkdir -p "$REPORT_DIR"

if [[ ! -x "$SCRIPT_DIR/chaosctl.sh" ]]; then
  echo "chaosctl.sh not found/executable at $SCRIPT_DIR"
  exit 1
fi

if [[ ! -x "/home/sidhant/scripts/service-integrity-check.sh" ]]; then
  echo "Integrity checker missing: /home/sidhant/scripts/service-integrity-check.sh"
  exit 1
fi

START_ISO=$(date -u +%Y-%m-%dT%H:%M:%SZ)
START_EPOCH=$(date +%s)
REPORT_DATE=$(date -u +%Y-%m-%d)
REPORT_PATH="$REPORT_DIR/${REPORT_DATE}-weekly-drill.md"

echo "Starting weekly chaos drill at $START_ISO"

set +e
DRILL_OUTPUT=$(CHAOS_ACK=I_UNDERSTAND "$SCRIPT_DIR/chaosctl.sh" stop "$TARGET_SERVICE" "$DURATION_SECONDS" 2>&1)
DRILL_EXIT=$?
set -e

set +e
INTEGRITY_OUTPUT=$(/home/sidhant/scripts/service-integrity-check.sh 2>&1)
INTEGRITY_EXIT=$?
set -e

END_ISO=$(date -u +%Y-%m-%dT%H:%M:%SZ)
END_EPOCH=$(date +%s)
ELAPSED_TOTAL=$((END_EPOCH - START_EPOCH))

if [[ -f "$LOG_FILE" ]]; then
  LAST_7D=$(date -u -d '7 days ago' +%Y-%m-%dT%H:%M:%SZ)
  KPI_BLOCK=$(LOG_FILE="$LOG_FILE" LAST_7D="$LAST_7D" python3 - <<'PY'
import datetime
import os
import re

log_file = os.environ.get("LOG_FILE")
cutoff_iso = os.environ.get("LAST_7D")
cutoff = datetime.datetime.fromisoformat(cutoff_iso.replace("Z", "+00:00"))

started = recovered = failed = 0
elapsed_sum = elapsed_count = 0

line_re = re.compile(r"^(\S+)\s+CHAOS_EVENT\s+(.*)$")
field_re = re.compile(r"(\w+)=([^\s]+)")

with open(log_file, "r", encoding="utf-8", errors="ignore") as f:
    for line in f:
        m = line_re.match(line.strip())
        if not m:
            continue
        ts = datetime.datetime.fromisoformat(m.group(1).replace("Z", "+00:00"))
        if ts < cutoff:
            continue
        fields = {k:v for k,v in field_re.findall(m.group(2))}
        phase = fields.get("phase", "")
        status = fields.get("status", "")
        if phase == "start":
            started += 1
        if phase == "end" and status == "recovered":
            recovered += 1
        if status == "failed":
            failed += 1
        if phase == "end" and fields.get("elapsed_sec", "").isdigit():
            elapsed_sum += int(fields["elapsed_sec"])
            elapsed_count += 1

avg_recovery = (elapsed_sum / elapsed_count) if elapsed_count else 0
print(f"started={started}")
print(f"recovered={recovered}")
print(f"failed={failed}")
print(f"avg_recovery={avg_recovery:.1f}")
PY
)
else
  KPI_BLOCK="started=0
recovered=0
failed=0
avg_recovery=0.0"
fi

STARTED=$(printf '%s\n' "$KPI_BLOCK" | grep '^started=' | cut -d= -f2)
RECOVERED=$(printf '%s\n' "$KPI_BLOCK" | grep '^recovered=' | cut -d= -f2)
FAILED=$(printf '%s\n' "$KPI_BLOCK" | grep '^failed=' | cut -d= -f2)
AVG_RECOVERY=$(printf '%s\n' "$KPI_BLOCK" | grep '^avg_recovery=' | cut -d= -f2)

STATUS="SUCCESS"
if [[ "$DRILL_EXIT" -ne 0 || "$INTEGRITY_EXIT" -ne 0 ]]; then
  STATUS="FAILED"
fi

cat > "$REPORT_PATH" <<EOF
# Weekly Chaos Drill - $REPORT_DATE

## Summary
- Status: **$STATUS**
- Start (UTC): $START_ISO
- End (UTC): $END_ISO
- Total runtime: ${ELAPSED_TOTAL}s
- Target service: $TARGET_SERVICE
- Planned disruption: ${DURATION_SECONDS}s stop/restart

## Outcome
- Drill exit code: $DRILL_EXIT
- Integrity check exit code: $INTEGRITY_EXIT

## Chaos KPIs (Last 7 Days)
- Experiments started: $STARTED
- Experiments recovered: $RECOVERED
- Experiment failures: $FAILED
- Avg recovery time (s): $AVG_RECOVERY

## Drill Command Output
\`\`\`
$DRILL_OUTPUT
\`\`\`

## Integrity Check Snapshot
\`\`\`
$(printf '%s\n' "$INTEGRITY_OUTPUT" | tail -n 40)
\`\`\`

## Grafana
- Chaos Control Center: https://grafana.homelabdev.space/d/chaos-center/chaos-control-center
- Chaos Reporting: https://grafana.homelabdev.space/d/chaos-reporting/chaos-reporting
EOF

echo "Weekly chaos report written: $REPORT_PATH"

if [[ "$STATUS" != "SUCCESS" ]]; then
  exit 1
fi
