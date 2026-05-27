---
name: steloit-explore
description: |
  Deep codebase exploration for tasks where the implementation direction
  is uncertain. Produces a direction report and creates phased kanban
  sub-tasks. Not for direct implementation.
  Usage: /steloit-explore <query>
argument-hint: <query>
agent: explorer
model: opus
effort: high
context: fork
run-in-subagent: true
disable-model-invocation: false
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - WebFetch
  - Task
  - mcp__steloit__list_tasks
  - mcp__steloit__create_task
  - mcp__steloit__get_project_context
  - mcp__steloit__add_note
---

# /steloit-explore — Explore for `<QUERY>`

Deeply explore the active codebase against `<QUERY>` to surface a
direction report and decompose the work into phased kanban tasks.

## Flow

1. Pull project context via `get_project_context`.
2. Run broad pattern searches (Grep/Glob) and targeted reads to map
   the relevant code surface.
3. Hop on entities discovered in the first pass (functions, types,
   call sites) up to 3 hops deep.
4. Synthesize a **direction report**: current state, target state,
   decisions to make, trade-offs, references.
5. Use `create_task` to create one task per implementation phase, with
   dependency pins.
6. Post the direction report as a signed note on a tracking task.

## Notes

- This is a discovery skill, **not** an implementation skill. The
  generated tasks are run later by `/steloit-run`.
- High reasoning effort: this is intentionally expensive and used when
  direction is genuinely uncertain.
