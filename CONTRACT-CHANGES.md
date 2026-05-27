# Contract changelog

Records every change to `contract/v1/` (and any future `contract/vN/`).
Per the versioning policy in `README.md`, `v1` is additive-safe:
optional fields may land in `v1` without bumping. Breaking changes
require a new `contract/v2/` directory.

## v1.0 — 2026-05-27

Initial publication of the public steloit template contract. Schemas
shipped:

- `contract/v1/placeholders.schema.json` — enum of all 24 placeholders
  the steloit-go prompt renderer substitutes at render time (14
  content + 10 stack).
- `contract/v1/frontmatter.schema.json` — required YAML frontmatter
  shape (8 keys: `name`, `description`, `role`, `model_key`,
  `signature`, `version`, `tags`, `rubric_ref`).
- `contract/v1/rubric.schema.json` — rubric YAML shape consumed by
  Critic and Inspector agents (`dimensions`, `score_range`,
  `decision_rule`, optional `anti_patterns`, `reason_codes`,
  `output_schema`).

Pinned source-of-truth SHA for the placeholder enum and the example
seed bodies: `fa7a43eb798daab66e4639f049324b5c80d16908` (steloit-go
HEAD touching `internal/prompt/substitute.go`).

### Placeholder reconciliation (20 → 24)

The refined task spec for #427 originally claimed "20 placeholders".
Verification against the pinned steloit-go SHA showed the true count
is **24**:

- `internal/prompt/substitute.go` defines the 10 `STACK_*`
  placeholders.
- `internal/prompt/prompt.go` (Step 7 values map) and
  `internal/prompt/renderforstage.go` together define **14 content
  placeholders**, not 10:
  `ROLE`, `TASK_ID`, `PROJECT_BRIEF_TITLE`, `PROJECT_BRIEF`,
  `DESCRIPTION`, `TEAM_CONVENTIONS`, `TEAM_GLOSSARY`,
  `CRITIC_STRICTNESS`, `PLAN`, `DONE_WHEN`, `DECISION_LOG`,
  `DEPENDENCY_CONTEXT`, `CRITIC_FEEDBACK`, `INSPECTOR_FEEDBACK`.
- Three names in the refined spec (`TITLE`, `IMPLEMENTATION_NOTES`,
  `DEPENDENCIES_CONTEXT` plural) **do not exist** in the renderer
  source. The spec was written from memory; code is source of truth.
  The schema reflects code.

### Soft-fail drift-diff

The `contract-lint.yml` workflow's `drift-diff` job soft-fails (WARN
annotation, exit 0) when the repository secret
`STELOIT_GO_RAW_TOKEN` is unset, because the upstream `steloit-go`
repo is private at v1 publish time. Hard-fail mode is toggled by
setting repository variable `CONTRACT_DRIFT_HARD_FAIL=true` once the
read-only PAT is plumbed.
