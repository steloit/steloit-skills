# Contributing

Thanks for your interest in contributing to `steloit-skills`. This
project is licensed Apache-2.0 and uses the Developer Certificate of
Origin (DCO). There is **no CLA**.

## Quick start

1. Fork the repo and clone your fork.
2. Make your changes on a feature branch.
3. Run the lint scripts locally:
   ```
   bash scripts/lint-public.sh
   bash scripts/validate-frontmatter.sh
   ```
4. Commit with sign-off:
   ```
   git commit -s -m "feat(skills): add new verb"
   ```
5. Open a pull request. The `dco` workflow will verify that **every
   commit** in your PR carries a `Signed-off-by:` trailer.

## DCO sign-off

By adding `Signed-off-by: Your Name <you@example.com>` to a commit you
are agreeing to the Developer Certificate of Origin (see `DCO.md`).

The simplest way to add it is via `git commit -s`:

```
git commit -s -m "your message"
```

You can configure your editor or git template to do this automatically.
If you forget on a single commit, amend it with
`git commit --amend -s`. If you forget across many commits in a branch,
rebase with `git rebase --signoff main`.

## What you can contribute

- New skill verbs (umbrella) or new workflow skills
- Improvements to `models.json` routing (add a new provider, refine a
  per-role default)
- Documentation fixes
- Lint rule improvements (`scripts/lint-public.sh`,
  `scripts/validate-frontmatter.sh`)

## What we will not accept

- Changes that reference closed-repo paths (the lint will block this)
- Inclusion of credentials or fixtures with real secrets
- Skill files that violate the Claude Code SKILL.md frontmatter schema
- Changes that re-license the project to anything other than Apache-2.0
- Changes that use the Steloit name or logo in ways prohibited by
  `TRADEMARK.md`

## Style

- Markdown: keep line length around 80 characters where reasonable
- Shell: POSIX `sh` for scripts, `set -e` at the top, Apache-2.0 header
- YAML: 2-space indent, no tabs

## Reporting security issues

Please **do not** open public issues for security problems. Use the
private flow documented in `SECURITY.md`.
