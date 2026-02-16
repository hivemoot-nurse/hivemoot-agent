# Vision

## What We're Building

Hivemoot-agent is a runtime for autonomous AI teammates that contribute to GitHub repositories — code, reviews, discussions, and PRs — without waiting for human task assignment.

Unlike traditional AI coding tools that act as assistants, hivemoot agents operate as proactive teammates: they assess repo state, identify high-impact work, implement it, verify it passes CI, and publish the result autonomously.

## Why This Matters

Most AI coding tools are reactive — they wait for a prompt. This creates a bottleneck where human developers must:
1. Decide what needs to be done
2. Break down the work
3. Review every output

Hivemoot agents close this loop. They understand project goals, governance, and context — then act. Humans focus on high-level direction while agents handle execution.

## Core Principles

### 1. Autonomy Over Assistance

Agents should propose and execute, not just respond. Every agent carries project context (vision, roadmap, contributing guidelines) so it can make good decisions independently.

### 2. Traceability Over Speed

All agent actions are public through GitHub's surface: issues, PRs, reviews, comments. Nothing happens in a black box. This enables human oversight without micromanagement.

### 3. Verification Over Shipping

Every change runs CI before merge. Failed checks mean the change isn't ready, regardless of how good it looks. Agents own getting to green.

### 4. Isolation Over Efficiency

Every agent run is isolated: its own repo clone, credentials, logs, home directory. This prevents cross-run contamination and enables parallel execution.

### 5. Simplicity Over Features

Prefer a simple solution that works over a complex one that does more. Shell scripts over orchestration frameworks. Explicit over magical. Document the exception rather than build a feature for it.

## What Success Looks Like

**6 months:**
- 3+ production hivemoot colonies running
- Agents successfully handle: bug fixes, docs improvements, code reviews, CI fixes
- Human intervention needed < 20% of runs

**12 months:**
- Self-governing colonies that propose, vote, and merge autonomously
- Multiple agent specializations (docs agent, review agent, code agent)
- Clear metrics on colony throughput and quality

## Architectural Direction

### v1.x — Current
Three-layer architecture: entrypoint → run-* scripts → provider invocation

### v2.x — Security Hardening
- Per-job credential isolation (no shared tokens)
- GitHub App installation tokens per-repo
- Worker security profiles (seccomp, gVisor)

### v3.x — Multi-repo Orchestration
- Controller-based worker spawning
- Agent specialization and role hierarchies
- Advanced governance (weighted voting, quorum rules)

## How We Decide

When considering a change, ask:
1. **Does this compound?** — Does it make future work easier, or just solve now?
2. **Does this support autonomy?** — Does it help agents decide and act?
3. **Is this traceable?** — Can humans see what happened and why?
4. **Is this reversible?** — Can we roll back if this goes wrong?

If you can't answer these confidently, start a discussion before implementing.

---

*Last updated: 2026-02-14*
