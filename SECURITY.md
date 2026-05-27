# Security Policy

## Reporting a vulnerability

If you believe you have found a security vulnerability in any Steloit
skill bundle, please report it **privately** via GitHub Security
Advisories on this repository:

<https://github.com/steloit/steloit-skills/security/advisories/new>

We will acknowledge receipt within **2 business days** and aim to
provide a fix or mitigation timeline within **10 business days**.

Please do not file public issues for suspected vulnerabilities.

## Scope

In scope:

- Skill files in `skills/*/SKILL.md`
- The signed release pipeline (`.github/workflows/release-skill.yml`)
- The lint and bundle-build scripts in `scripts/`
- `models.json` routing

Out of scope (report upstream):

- Vulnerabilities in `cosign`, `sigstore-go`, or other Sigstore tooling
- Vulnerabilities in the GitHub Actions runner platform
- Vulnerabilities in Claude Code or Codex runtimes themselves

## Supply chain

All release artifacts are signed via Sigstore Fulcio keyless signing
with an OIDC identity pinned to this exact workflow file. The
certificate identity regex is:

```
^https://github\.com/steloit/steloit-skills/\.github/workflows/release-skill\.yml@refs/tags/skill-v[0-9]+\.[0-9]+\.[0-9]+$
```

The Steloit CLI verifies this regex on every install and update. We
never publish artifacts without a Sigstore bundle, and we never use
`--insecure-ignore-tlog`.
