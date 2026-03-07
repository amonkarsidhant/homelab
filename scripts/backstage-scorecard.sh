#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CATALOG_FILE="$REPO_DIR/backstage/catalog/all.yaml"
OUTPUT_FILE="${1:-$REPO_DIR/docs/backstage-scorecard.md}"

python3 - "$CATALOG_FILE" "$OUTPUT_FILE" <<'PY'
import sys
from pathlib import Path

import yaml

catalog_path = Path(sys.argv[1])
output_path = Path(sys.argv[2])
docs = list(yaml.safe_load_all(catalog_path.read_text()))

rows = []
errors = []

for doc in docs:
    if not isinstance(doc, dict) or doc.get("kind") != "Component":
        continue

    metadata = doc.get("metadata") or {}
    spec = doc.get("spec") or {}
    annotations = metadata.get("annotations") or {}
    links = metadata.get("links") or []
    titles = {str(link.get("title", "")).strip() for link in links if isinstance(link, dict)}

    score = 0
    checks = {
        "owner": bool(spec.get("owner")),
        "lifecycle": bool(spec.get("lifecycle")),
        "system": bool(spec.get("system")),
        "tier": "homelab.dev/tier" in annotations,
        "criticality": "homelab.dev/criticality" in annotations,
        "runbook_annotation": "homelab.dev/runbook" in annotations,
        "gitea_repo": "homelab.dev/gitea-repo" in annotations,
        "source_link": "Source Directory" in titles,
        "runbook_link": "Runbook" in titles,
        "cicd_link": "CI/CD (Gitea Actions)" in titles,
    }
    score = sum(1 for ok in checks.values() if ok) / len(checks)

    criticality = annotations.get("homelab.dev/criticality", "unknown")
    lifecycle = spec.get("lifecycle", "unknown")
    name = metadata.get("name", "unknown")

    status = "healthy" if score >= 0.9 else "watch" if score >= 0.7 else "at-risk"
    rows.append((name, lifecycle, criticality, score, status, checks))

    if lifecycle == "production" and criticality == "high" and score < 0.8:
        errors.append(f"{name} score {score:.2f} below high-critical threshold 0.80")

rows.sort(key=lambda r: r[0])

lines = []
lines.append("# Backstage Service Scorecard")
lines.append("")
lines.append("Cortex-inspired operational scorecard generated from `backstage/catalog/all.yaml`.")
lines.append("")
lines.append("Scoring dimensions (10): owner, lifecycle, system, tier, criticality, runbook annotation, gitea repo annotation, source link, runbook link, CI/CD link.")
lines.append("")
lines.append("| Component | Lifecycle | Criticality | Score | Status |")
lines.append("| --- | --- | --- | ---: | --- |")
for name, lifecycle, criticality, score, status, _ in rows:
    lines.append(f"| `{name}` | `{lifecycle}` | `{criticality}` | `{score:.2f}` | `{status}` |")

output_path.parent.mkdir(parents=True, exist_ok=True)
output_path.write_text("\n".join(lines) + "\n")

print(f"Wrote scorecard report: {output_path}")
for _, _, _, _, _, checks in rows:
    _ = checks

if errors:
    print("Scorecard policy violations:")
    for err in errors:
        print(f"- {err}")
    sys.exit(1)

print("Scorecard policy checks passed.")
PY
