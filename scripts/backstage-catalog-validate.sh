#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CATALOG_FILE="$REPO_DIR/backstage/catalog/all.yaml"

python3 - "$CATALOG_FILE" <<'PY'
import sys
from pathlib import Path

import yaml

catalog_path = Path(sys.argv[1])
docs = list(yaml.safe_load_all(catalog_path.read_text()))

errors = []

required_annotations = {
    "homelab.dev/tier",
    "homelab.dev/criticality",
    "homelab.dev/runbook",
}

for idx, doc in enumerate(docs, start=1):
    if not isinstance(doc, dict):
        continue

    kind = doc.get("kind")
    if kind != "Component":
        continue

    metadata = doc.get("metadata") or {}
    spec = doc.get("spec") or {}
    name = metadata.get("name", f"component@{idx}")

    if not spec.get("owner"):
        errors.append(f"{name}: missing spec.owner")
    if not spec.get("lifecycle"):
        errors.append(f"{name}: missing spec.lifecycle")
    if not spec.get("system"):
        errors.append(f"{name}: missing spec.system")

    annotations = metadata.get("annotations") or {}
    missing = sorted(required_annotations - set(annotations.keys()))
    if missing:
        errors.append(f"{name}: missing annotations {', '.join(missing)}")

    links = metadata.get("links") or []
    if not links:
        errors.append(f"{name}: missing metadata.links")
        continue

    titles = {str(link.get("title", "")).strip() for link in links if isinstance(link, dict)}
    has_source = "Source Directory" in titles
    has_runbook = "Runbook" in titles
    if not (has_source or has_runbook):
        errors.append(f"{name}: links should include 'Source Directory' or 'Runbook'")

if errors:
    print("Backstage catalog validation failed:")
    for err in errors:
        print(f"- {err}")
    sys.exit(1)

print("Backstage catalog validation passed.")
PY
