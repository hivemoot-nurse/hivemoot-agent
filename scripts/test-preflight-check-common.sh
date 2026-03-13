#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local file="$1"
  local needle="$2"
  if ! grep -Fq "$needle" "$file"; then
    echo "Expected to find: $needle" >&2
    echo "Actual output:" >&2
    sed 's/^/  /' "$file" >&2
    fail "assertion failed"
  fi
}

run_preflight() {
  local stderr_file="$1"
  shift

  "$@" > /dev/null 2> "$stderr_file"
}

echo "Running shared preflight helper checks"

tmp_root="$(mktemp -d)"
cleanup() {
  rm -rf "$tmp_root"
}
trap cleanup EXIT

mock_bin="${tmp_root}/bin"
mkdir -p "$mock_bin"

cat > "${mock_bin}/claude" <<'EOF_CLAUDE'
#!/usr/bin/env bash
exit 0
EOF_CLAUDE
chmod +x "${mock_bin}/claude"

prompt_file="${tmp_root}/prompt.md"
printf 'standalone prompt\n' > "$prompt_file"

export PATH="${mock_bin}:/usr/bin:/bin"

# shellcheck source=scripts/lib.sh
. scripts/lib.sh

gh() {
  local args=" $* "

  if [ "${1:-}" != "api" ]; then
    return 1
  fi

  if [[ "$args" == *" user "* ]]; then
    if [ "${GH_TOKEN:-}" = "user-token" ]; then
      printf 'mock-user\n'
      return 0
    fi
    return 1
  fi

  if [[ "$args" == *" installation "* ]]; then
    if [ "${GH_TOKEN:-}" = "install-token" ]; then
      printf '1\n'
      return 0
    fi
    return 1
  fi

  if [[ "$args" == *" repos/owner/repo "* ]]; then
    case "${GH_TOKEN:-}" in
      user-token|install-token)
        printf 'owner/repo\n'
        return 0
        ;;
    esac
    return 1
  fi

  return 1
}

declare -A seen_agents=()
declare -A agent_skill_lists=()
declare -a agent_ids=("worker")
declare -a agent_tokens=("install-token")

stderr_file="${tmp_root}/stderr.log"

if ! run_preflight "$stderr_file" preflight_check_common claude subscription "$prompt_file" owner/repo 0 0; then
  sed 's/^/  /' "$stderr_file" >&2 || true
  fail "expected install token to pass in periodic mode without hivemoot CLI"
fi

if run_preflight "$stderr_file" preflight_check_common claude subscription "$prompt_file" owner/repo 1 0; then
  fail "expected install token to fail when WATCH_MENTIONS=1"
fi
assert_contains "$stderr_file" "Pre-flight: token for agent 'worker' is not a valid user token (required for WATCH_MENTIONS=1)."

if run_preflight "$stderr_file" preflight_check_common claude subscription "$prompt_file" owner/repo 0 1; then
  fail "expected missing hivemoot CLI to fail when required"
fi
assert_contains "$stderr_file" "Pre-flight: hivemoot CLI is not installed."

cat > "${mock_bin}/hivemoot" <<'EOF_HIVEMOOT'
#!/usr/bin/env bash
exit 0
EOF_HIVEMOOT
chmod +x "${mock_bin}/hivemoot"

agent_tokens=("user-token")
if ! run_preflight "$stderr_file" preflight_check_common claude subscription "$prompt_file" owner/repo 1 1; then
  sed 's/^/  /' "$stderr_file" >&2 || true
  fail "expected user token + hivemoot CLI to pass for mention watching"
fi

echo "PASS: shared preflight helper checks"
