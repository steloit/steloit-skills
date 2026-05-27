---
name: steloit-ask
description: |
  Q&A against Steloit Sage — the project memory and wiki. Answers
  questions about the project's ADRs, design decisions, prior tasks,
  and architectural conventions.
  Usage: /steloit-ask <question>
argument-hint: <question>
agent: sage
model: sonnet
effort: medium
context: fork
run-in-subagent: true
disable-model-invocation: false
allowed-tools:
  - Read
  - Bash
  - WebFetch
  - mcp__steloit__get_project_context
  - mcp__steloit__get_task
  - mcp__steloit__get_task_audit
---

# /steloit-ask — Ask Steloit Sage `<QUESTION>`

Answer `<QUESTION>` from the project's memory: ADRs, wiki entries,
prior task audit logs, and the architecture overview.

## Flow

1. Fetch project context.
2. Search the wiki and ADR index for terms in `<QUESTION>`.
3. Cross-reference against recently-completed task audit logs.
4. Synthesize a concise answer with explicit citations to ADR numbers,
   wiki paths, and task IDs.
5. Flag uncertainty explicitly. If no source supports the answer, say
   so — do not invent.

## Notes

- `context: fork` — Sage runs in a fresh subagent. Each invocation is
  independent; follow-up questions re-fetch the relevant memory.
- Sage never modifies tasks; it is a read-only research role.
