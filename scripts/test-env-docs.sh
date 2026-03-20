#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
ENV_EXAMPLE_FILE="${REPO_ROOT}/.env.example"

declare -A documented_vars=()

compose_files=(
  "${REPO_ROOT}/docker-compose.yml"
  "${REPO_ROOT}/docker-compose.subscription.local.yml"
)

if [ ! -f "$ENV_EXAMPLE_FILE" ]; then
  echo "Missing .env.example at ${ENV_EXAMPLE_FILE}" >&2
  exit 1
fi

while IFS='=' read -r var_name _; do
  case "$var_name" in
    ''|\#*)
      continue
      ;;
  esac
  documented_vars["$var_name"]=1
done < "$ENV_EXAMPLE_FILE"

fail=0
while IFS= read -r compose_file; do
  [ -f "$compose_file" ] || continue

  while IFS= read -r var; do
    [ -n "$var" ] || continue
    if [ -z "${documented_vars[$var]:-}" ]; then
      echo "::error file=$(basename "$compose_file")::${var} is used in $(basename "$compose_file") but missing from .env.example" >&2
      fail=1
    fi
  done < <(grep -oE '\$\{[A-Z][A-Z0-9_]*:-' "$compose_file" | sed -E 's/^\$\{([A-Z][A-Z0-9_]*)[:]-$/\1/' | sort -u)
done < <(printf '%s\n' "${compose_files[@]}")

if [ "$fail" -ne 0 ]; then
  exit 1
fi

echo "PASS: compose variables are documented in .env.example"
