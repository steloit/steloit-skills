# steloit-skills

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Release](https://img.shields.io/github/v/tag/steloit/steloit-skills?filter=skill-v*)](https://github.com/steloit/steloit-skills/releases)
[![Sigstore](https://img.shields.io/badge/signed-sigstore-blueviolet)](https://www.sigstore.dev/)

Public, Apache-2.0 licensed slash-command skill bundle for the Steloit
agent pipeline.

Ships:

- **1 umbrella skill** (`steloit`) with 10 CRUD verbs dispatched via
  `$ARGUMENTS`: `list`, `add`, `show`, `move`, `comment`, `note`,
  `context`, `project`, `stats`, `audit`.
- **5 workflow skills**: `steloit-run`, `steloit-refine`,
  `steloit-explore`, `steloit-ask`, `steloit-review`.
- **`models.json`** declaring per-role × per-runtime model routing for
  both `claude` and `codex` providers.

Released as a signed `.tar.zst` bundle on every `skill-v*` tag via the
Sigstore Fulcio keyless flow.

## Open-core split

Per `ADR-0005`, Steloit is built as an open core:

- **This repo (open, Apache-2.0)** — the skill files, models routing,
  and bundle release pipeline. Anyone can fork, audit, and redistribute
  the code under Apache-2.0.
- **The server (closed)** — the orchestrator, state machine, prompt
  renderer, dashboard, and billing live in a separate, proprietary
  repository owned by Steloit <!-- lint-allow: closed-repo-ref -->

The two are connected through:

- `models.json` — provider/role routing the server consumes when
  spawning subagents.
- A documented MCP tool surface — wrapped by the umbrella verbs.
- A bundle-manifest API — server publishes the canonical
  `latest-skill-bundle` pointer for the CLI installer.

The full split is described in `ADR-0005`, the hybrid skill layout in
`ADR-0031`, and the signing trust model in `ADR-0046`.

## Install

The skill bundle is installed by the Steloit CLI:

```
steloit init                 # installs the latest stable bundle
steloit skills update        # refresh to latest stable
steloit skills verify        # re-run Sigstore verification offline
steloit skills install --version skill-v0.1.0   # pin a specific tag
```

### Manual verification

Each release publishes three artifacts on the GitHub release page:

- `skill-bundle-v{version}.tar.zst`
- `skill-bundle-v{version}.tar.zst.sigstore.json` (Sigstore protobuf bundle)
- `sha256sums.txt`

Verify the bundle yourself with `cosign`:

```
cosign verify-blob \
  --certificate-identity-regexp '^https://github\.com/steloit/steloit-skills/\.github/workflows/release-skill\.yml@refs/tags/skill-v[0-9]+\.[0-9]+\.[0-9]+$' \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  --bundle skill-bundle-v0.1.0.tar.zst.sigstore.json \
  skill-bundle-v0.1.0.tar.zst
```

The certificate identity is pinned to **this exact workflow file path**
under **this exact repo**. Any reuse of the workflow under a different
path or repo will fail verification by design.

## Layout

```
.
├── skills/
│   ├── steloit/SKILL.md          # umbrella, 10 CRUD verbs via $ARGUMENTS
│   ├── steloit-run/SKILL.md      # workflow: execute one pipeline step
│   ├── steloit-refine/SKILL.md   # workflow: refine task description
│   ├── steloit-explore/SKILL.md  # workflow: deep codebase exploration
│   ├── steloit-ask/SKILL.md      # workflow: ask Steloit Sage
│   └── steloit-review/SKILL.md   # workflow: multi-agent PR review
├── models.json                   # claude + codex × 10 roles
├── LICENSE / NOTICE              # Apache-2.0
├── TRADEMARK.md                  # trademark policy (separate from license)
├── CONTRIBUTING.md               # DCO sign-off required
├── SECURITY.md                   # private vulnerability reporting
├── scripts/
│   ├── lint-public.sh
│   ├── validate-frontmatter.sh
│   └── build-bundle.sh
└── .github/workflows/
    ├── release-skill.yml         # tag-triggered Sigstore-signed release
    ├── lint.yml
    └── dco.yml
```

## Contract

`contract/v1/` publishes the public **steloit template contract** —
the source-of-truth schemas third-party template authors validate
against before submitting a custom template via the dashboard (#428)
or API. The contract is intentionally separate from this repo's
Claude Code skill bundle: agents, workflows, and rubrics live in
tenant Postgres, authored via the dashboard; the contract defines
their shape.

- [`contract/v1/placeholders.schema.json`](contract/v1/placeholders.schema.json)
  — enum of the 24 `<UPPERCASE_UNDERSCORE>` placeholders the
  steloit-go prompt renderer substitutes (14 content + 10 stack).
- [`contract/v1/frontmatter.schema.json`](contract/v1/frontmatter.schema.json)
  — required YAML frontmatter shape for any template (8 keys).
- [`contract/v1/rubric.schema.json`](contract/v1/rubric.schema.json)
  — rubric YAML shape consumed by Critic and Inspector agents.

Validate a template locally:

```
pip install -r scripts/requirements.txt
./scripts/validate-template.sh path/to/template.md
```

Examples live in [`examples/`](examples/); the editor that produces
production templates is shipped by #428 (dashboard URL TBD). Contract
evolution is recorded in [`CONTRACT-CHANGES.md`](CONTRACT-CHANGES.md).
`v1` is additive-safe; breaking changes ship as `v2/`.

## Contributing

We accept contributions under the Apache-2.0 patent grant. Every commit
must be signed off per the Developer Certificate of Origin (DCO):

```
git commit -s -m "your message"
```

See `CONTRIBUTING.md` for the full flow and `DCO.md` for the certificate
text. There is no separate CLA.

## Trademark

The source code in this repository is Apache-2.0. The name "Steloit"
and the Steloit logo are trademarks of the Steloit project and are
**not** covered by the Apache-2.0 license. See `TRADEMARK.md` for what
fork names are permitted.

## Security

Please report vulnerabilities privately via the GitHub Security
Advisories tab on this repository. See `SECURITY.md` for the full flow.
