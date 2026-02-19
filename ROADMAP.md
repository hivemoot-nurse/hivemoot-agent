# ROADMAP.md

This document captures the architectural direction for hivemoot-agent, evolving from the discussions in [#6](https://github.com/hivemoot/hivemoot-agent/issues/6).

## Design Principles

- **Container = security boundary** — not path separation within a container
- **Ephemeral workers** over long-lived containers
- **Simple before flexible** — shell scripts first
- Both orchestration paths coexist: in-container for simple setups, controller for production

## Phases

### Phase 0 (shipped)

Core runtime with multi-provider, multi-agent, per-agent isolation.

### Phase 1 (#16)

**Worker boundary hardening**

- `JOB_ID` isolation for all runs
- Per-job HOME and workspace directories
- Selective auth credential seeding (only what's needed, no session state)
- Threat model documentation

### Phase 2 (#17)

**Controller MVP**

External orchestrator spawning ephemeral worker containers.

### Phase 3 (#18)

**Repo-scoped credentials**

GitHub App installation tokens instead of user PATs.

### Phase 4 (#19)

**Worker security hardening**

- seccomp profiles
- gVisor integration
- Resource limits (CPU, memory)

### Phase 5 (#20)

**Containerized controller**

Restricted launcher API for controlled worker spawning.
