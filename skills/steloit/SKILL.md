---
name: steloit
description: |
  Umbrella slash command for Steloit task and project CRUD operations.
  Dispatches one of 10 verbs via $ARGUMENTS:
    list, add, show, move, comment, note, context, project, stats, audit.
  Usage: /steloit <verb> [args...]
argument-hint: <verb> [args...]
allowed-tools:
  - Read
  - Bash
  - mcp__steloit__list_tasks
  - mcp__steloit__create_task
  - mcp__steloit__get_task
  - mcp__steloit__move_task
  - mcp__steloit__add_comment
  - mcp__steloit__add_note
  - mcp__steloit__get_project_context
  - mcp__steloit__list_projects
  - mcp__steloit__switch_project
  - mcp__steloit__get_project_stats
  - mcp__steloit__get_task_audit
disable-model-invocation: false
run-in-subagent: false
---

# /steloit — Task and project CRUD

This is the **umbrella** slash command for Steloit. It dispatches on
the first word of `$ARGUMENTS` to one of ten CRUD verbs, each wrapping a
single MCP tool.

Parse `$ARGUMENTS` as `<verb> [rest...]`. Match `<verb>` against the
sections below. If the verb is unknown or missing, print usage and exit.

Usage summary:

```
/steloit list
/steloit add <title>
/steloit show <id>
/steloit move <id> <status>
/steloit comment <id> <text>
/steloit note <id> <text>
/steloit context
/steloit project [list|switch <name>]
/steloit stats
/steloit audit <id>
```

---

### /steloit list

List tasks in the active project.

- **MCP tool**: `list_tasks`
- **Args**: none (optional `--status <col>`, `--limit <n>`)

Example:

```
/steloit list
/steloit list --status doing --limit 10
```

---

### /steloit add

Create a new task in the active project.

- **MCP tool**: `create_task`
- **Args**: `<title>` (required); body read from prompt if absent

Examples:

```
/steloit add "wire OpenAPI codegen"
/steloit add "spike: postgres LSN reader"
```

---

### /steloit show

Show full detail for a task.

- **MCP tool**: `get_task`
- **Args**: `<id>` (required, integer)

Example:

```
/steloit show 258
```

---

### /steloit move

Move a task to a different column.

- **MCP tool**: `move_task`
- **Args**: `<id> <status>` (status one of: backlog, todo, doing, review, done)

Example:

```
/steloit move 258 review
```

---

### /steloit comment

Append a typed **user** comment on a task. Comments are user-authored
notes that show up in the timeline.

- **MCP tool**: `add_comment`
- **Args**: `<id> <text>` (text may contain spaces)

Example:

```
/steloit comment 258 "please double-check the cert regex"
```

---

### /steloit note

Append a typed **system** note on a task. Notes are agent/system-authored
audit-trail entries distinct from user comments.

- **MCP tool**: `add_note`
- **Args**: `<id> <text>`

Example:

```
/steloit note 258 "shield: 17/17 tests pass"
```

---

### /steloit context

Fetch the active project's memory and dependency graph for the current
session. Useful at session start to prime an agent.

- **MCP tool**: `get_project_context`
- **Args**: none

Example:

```
/steloit context
```

---

### /steloit project

Project-management subcommands.

- **MCP tool**: `list_projects` or `switch_project`
- **Args**: `list` or `switch <name>`

Examples:

```
/steloit project list
/steloit project switch steloit-go
```

---

### /steloit stats

Show pipeline statistics for the active project (counts per column,
average dwell time, etc.).

- **MCP tool**: `get_project_stats`
- **Args**: none

Example:

```
/steloit stats
```

---

### /steloit audit

Render the full audit trail for a task: every status transition, every
agent action, every comment and note, in chronological order.

- **MCP tool**: `get_task_audit`
- **Args**: `<id>`

Example:

```
/steloit audit 258
```
