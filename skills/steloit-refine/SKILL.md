---
name: steloit-refine
description: |
  Interactively refine a Steloit task's description through a structured
  Socratic dialogue. Turns rough requirements into a concrete brief with
  goal, scope, acceptance criteria, edge cases, and cross-task pins.
  Usage: /steloit-refine <task-id>
argument-hint: <task-id>
agent: refiner
model: opus
effort: medium
context: fork
run-in-subagent: true
disable-model-invocation: false
allowed-tools:
  - Read
  - Bash
  - WebFetch
  - Task
  - AskUserQuestion
  - mcp__steloit__get_task
  - mcp__steloit__add_comment
  - mcp__steloit__add_note
---

# /steloit-refine — Refine task `<TASK_ID>` interactively

Refine the description of task `<TASK_ID>` through a structured user
interview.

## Flow

1. Fetch the task via `get_task`.
2. Re-read any prior refinement notes from the audit log.
3. Ask the user 3–5 probing questions, one round at a time, via
   `AskUserQuestion`.
4. After each round, summarize what's now clear and what remains
   ambiguous; ask again until the brief is complete.
5. Produce a final brief with: **Goal**, **Scope (IN/OUT)**,
   **Requirements (numbered, testable)**, **Acceptance Criteria**,
   **Edge Cases**, **Cross-task pins**, **Wiki refs**.
6. Append the brief to the task via `add_note` (signed) and update the
   task body via the MCP `update_task` tool when available.

## Notes

- This skill is interactive by design. It runs in a forked subagent so
  the user's session focus is not lost.
- Refinement is iterative: a task can be refined multiple times. Each
  round produces a fresh signed note.
