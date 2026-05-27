---
name: steloit-run
description: |
  Execute one pipeline step (Planner, Critic, Builder, Shield, Inspector,
  or Ranger) on a Steloit task. The orchestrator picks the next role
  from the task's state; this skill spawns that role in a fresh forked
  subagent and posts results back via the MCP server.
  Usage: /steloit-run <task-id>
argument-hint: <task-id>
agent: orchestrator
model: opus
effort: high
context: fork
run-in-subagent: true
disable-model-invocation: false
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Task
  - WebFetch
  - mcp__steloit__get_task
  - mcp__steloit__move_task
  - mcp__steloit__add_note
  - mcp__steloit__get_project_context
  - mcp__steloit__get_task_audit
---

# /steloit-run — Execute one pipeline step on `<TASK_ID>`

Run the next pipeline step for the task identified by `<TASK_ID>`.

The role for `<TASK_ID>` is resolved from the task's current column
(e.g., `todo → Planner`, `planned → Critic`, `building → Builder`).
The per-role model is read from `models.json` for the active runtime
provider.

## Flow

1. Resolve task `<TASK_ID>` via `get_task`.
2. Read project context via `get_project_context`.
3. Determine next role from the task's status column.
4. Spawn a forked subagent with that role's identity, model, and
   reasoning effort (from `models.json`).
5. Subagent performs the role-specific work (plan, review, build,
   test, inspect, or release).
6. Persist outputs back to the task: `move_task` (column transition) +
   `add_note` (signed agent log entry).

## Notes

- `context: fork` — each invocation runs in a fresh subagent. The
  parent session is not polluted with role-specific state.
- The role identity, model, and prompt are rendered server-side; this
  skill is a thin client that triggers the rendering.
- For Codex, `effort` is honored via the `reasoning_effort` map in
  `models.json`.
