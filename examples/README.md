# Example templates

Example templates. Copy into your dashboard via #428's editor and
customize for your org. These files are **starting points**, not
production templates — production templates live in tenant Postgres
authored via the dashboard.

- `example-planner.md` — wraps the `default-coding/planner.md` seed
  body from steloit-go (pinned SHA
  `fa7a43eb798daab66e4639f049324b5c80d16908`) with the required v1
  frontmatter and signature header.
- `example-critic.md` — same shape for the Critic role; references
  `rubrics/example-plan-review.yaml` to demonstrate `rubric_ref`
  resolution.
- `rubrics/example-plan-review.yaml` — example rubric showing the full
  v1 shape (dimensions, anti-patterns, reason codes, output_schema,
  decision_rule).

Validate locally:

```
pip install -r ../scripts/requirements.txt
../scripts/validate-template.sh example-planner.md example-critic.md
```

The CI workflow `contract-lint.yml` runs the same check on every PR,
plus a tamper-fixture stage and a drift-diff against the upstream
seed bodies in steloit-go.
