#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

COMPOSE_FILES=(
  "traefik/docker-compose.yml"
  "observability/docker-compose.yml"
  "gitea/docker-compose.yml"
  "act-runner/docker-compose.yml"
  "backstage/docker-compose.yml"
  "goalert/docker-compose.yml"
)

declare -A service_owner
declare -A container_owner
errors=0

check_bash_syntax() {
  printf '==> Checking shell script syntax\n'
  while IFS= read -r script; do
    bash -n "$script"
  done < <(find "$REPO_DIR/scripts" -type f -name '*.sh' | sort)
}

collect_compose_ownership() {
  local file="$1"
  awk -v file="$file" '
    BEGIN {
      in_services = 0
      current_service = ""
    }

    /^services:[[:space:]]*$/ {
      in_services = 1
      next
    }

    /^[^[:space:]].*:[[:space:]]*$/ && $0 !~ /^services:[[:space:]]*$/ {
      if (in_services) {
        in_services = 0
        current_service = ""
      }
    }

    in_services && $0 ~ /^  [A-Za-z0-9_.-]+:[[:space:]]*$/ {
      current_service = $0
      sub(/^  /, "", current_service)
      sub(/:[[:space:]]*$/, "", current_service)
      printf("service\t%s\t%s\n", current_service, file)
      next
    }

    in_services && current_service != "" && $0 ~ /^    container_name:[[:space:]]*[^[:space:]]+[[:space:]]*$/ {
      container_name = $0
      sub(/^    container_name:[[:space:]]*/, "", container_name)
      sub(/[[:space:]]*$/, "", container_name)
      printf("container\t%s\t%s\n", container_name, file)
      next
    }
  ' "$REPO_DIR/$file"
}

check_compose_ownership() {
  printf '==> Checking compose ownership overlaps\n'
  local file line kind name source

  for file in "${COMPOSE_FILES[@]}"; do
    while IFS= read -r line; do
      kind="${line%%$'\t'*}"
      line="${line#*$'\t'}"
      name="${line%%$'\t'*}"
      source="${line#*$'\t'}"

      if [[ "$kind" == "service" ]]; then
        if [[ -n "${service_owner[$name]:-}" && "${service_owner[$name]}" != "$source" ]]; then
          printf 'ERROR: service "%s" declared in both %s and %s\n' "$name" "${service_owner[$name]}" "$source"
          errors=$((errors + 1))
        else
          service_owner[$name]="$source"
        fi
      fi

      if [[ "$kind" == "container" ]]; then
        if [[ -n "${container_owner[$name]:-}" && "${container_owner[$name]}" != "$source" ]]; then
          printf 'ERROR: container_name "%s" declared in both %s and %s\n' "$name" "${container_owner[$name]}" "$source"
          errors=$((errors + 1))
        else
          container_owner[$name]="$source"
        fi
      fi
    done < <(collect_compose_ownership "$file")
  done
}

main() {
  cd "$REPO_DIR"
  check_bash_syntax
  check_compose_ownership
  "$REPO_DIR/scripts/backstage-catalog-validate.sh"
  "$REPO_DIR/scripts/backstage-scorecard.sh" "$REPO_DIR/docs/backstage-scorecard.md"

  if [[ "$errors" -gt 0 ]]; then
    printf 'Preflight failed with %d overlap error(s).\n' "$errors"
    exit 1
  fi

  printf 'Preflight checks passed.\n'
}

main "$@"
