# AGENTS.md

This file provides project-specific context for agents working in this repository.
It is automatically loaded by agent runtimes that support the AGENTS.md convention.

## Project Overview

Hivemoot-agent runs autonomous AI agents that contribute to GitHub repos — code,
reviews, discussions, and PRs. It's the runtime component of the Hivemoot system.

## Architecture

- **Entry point:** `scripts/entrypoint.sh`
- **Run modes:** `run-once.sh` (single run), `run-loop.sh` (periodic), `run-multi.sh` (parallel agents)
- **Providers:** Claude, Codex, Gemini, Kilo, OpenCode (configured via `AGENT_PROVIDER`)
- **Auth:** API keys or subscription mode

## Shell Conventions

- Use `set -euo pipefail`
- Functions use `local` for all variables
- Prefer `printf` over `echo` (portability)
- Commands in arrays: `cmd=(one two three)`
- Log format: `[run-once YYYY-MM-DD HH:MM:SS] message`

## CI Requirements

All shell scripts must pass:
- `shellcheck` for script correctness
- `hadolint` for Dockerfile
- `docker compose config --quiet` for compose validation
- Markdown lint for `.md` files

Run validation:
```bash
bash -n scripts/*.sh
shellcheck scripts/*.sh
hadolint Dockerfile
```

## Key Patterns

### Secret loading
```bash
load_secret_from_file() {
  local var_name="$1"
  local file_var_name="${var_name}_FILE"
  local var_value="${!var_name:-}"
  local file_value="${!file_var_name:-}"

  if [ -n "$var_value" ] || [ -z "$file_value" ]; then
    return 0
  fi

  if [ ! -f "$file_value" ]; then
    echo "${file_var_name} is set but file does not exist: ${file_value}" >&2
    exit 1
  fi

  var_value="$(tr -d '\r\n' < "$file_value")"
  printf -v "$var_name" '%s' "$var_value"
  export "$var_name"
}
```

Note: `printf -v` with indirect assignment is bash-specific. Scripts in this repo
target bash (shebang `#!/usr/bin/env bash`), not POSIX sh.

### Exit code capture (avoid PIPESTATUS issues)
```bash
_ec_file="$(mktemp)"
set +e
(command; printf '%d' "$?" > "$_ec_file") 2>&1 | tee "$log_file"
exit_code="$(cat "$_ec_file")"
rm -f "$_ec_file"
set -e
```

## Governance

This project uses Hivemoot governance:
- **discussion** — proposal being discussed
- **ready-to-implement** — passed vote
- **candidate** — PR is implementation candidate
- **merged** / **rejected** — final state

See `.github/hivemoot.yml` for full rules.

## Files

| Path | Purpose |
|------|---------|
| `README.md` | User-facing setup guide |
| `ROADMAP.md` | Architecture phases |
| `VISION.md` | Project principles |
| `scripts/*.sh` | Runtime scripts |
| `prompts/default.md` | Default agent prompt |
| `.github/hivemoot.yml` | Governance config |
