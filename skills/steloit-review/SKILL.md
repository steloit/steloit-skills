---
name: steloit-review
description: |
  Multi-agent code review of a pull request. Runs the PR through
  Critic, Shield, and Inspector personas and produces a consolidated
  review comment.
  Usage: /steloit-review <PR>
argument-hint: <pr-url-or-number>
agent: reviewer
model: opus
effort: high
context: fork
run-in-subagent: true
disable-model-invocation: false
allowed-tools:
  - Bash
  - Read
  - WebFetch
  - Task
  - mcp__steloit__get_task
  - mcp__steloit__add_comment
  - mcp__steloit__add_note
---

# /steloit-review — Review pull request `<PR>`

Run a multi-agent code review of `<PR>` (a GitHub PR URL or numeric
PR ID against the active project's repo).

## Flow

1. Fetch the PR diff via `gh pr diff` and the PR metadata via
   `gh pr view`.
2. Spawn three forked subagents in parallel:
   - **Critic** — assesses plan/scope alignment and design choices.
   - **Shield** — runs the test suite and reports coverage gaps.
   - **Inspector** — looks for correctness bugs and edge cases.
3. Consolidate the three reviews into a single comment, deduplicating
   findings and ranking by severity.
4. Post the consolidated review back to the PR via `gh pr review` and
   to the linked task via `add_note` (signed).

## Notes

- `context: fork` — each reviewer runs in isolation; the consolidator
  is the parent.
- High reasoning effort: bugs missed here cascade into production.
- This skill never auto-merges. The human owner makes the merge call.
