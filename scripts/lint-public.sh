#!/usr/bin/env bash
# Copyright 2026 Steloit
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#     http://www.apache.org/licenses/LICENSE-2.0
#
# lint-public.sh — verify the public repo carries no proprietary leakage.
#
# Invariants:
#   1. No closed-repo path references outside README.md + docs/
#   2. No INTERNAL_ONLY / PROPRIETARY / DO_NOT_RELEASE markers
#   3. No credential patterns (sk_live_, sk_test_, whsec_, ghp_, etc.)
#   4. No STELOIT_* env names outside the public set
#   5. LICENSE contains "Apache License"
#   6. NOTICE file present
#   7. Apache headers on .sh files
#
# Lines that legitimately reference closed paths may carry an inline
# `# lint-allow: closed-repo-ref` marker.

set -eu

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

FAIL=0
fail() {
    echo "ERR: $1" >&2
    FAIL=1
}

# Prefer ripgrep when available; fall back to grep -rE for portability.
if command -v rg >/dev/null 2>&1; then
    SEARCH() { rg -n --no-heading "$@" 2>/dev/null || true; }
else
    SEARCH() {
        # crude fallback: grep -rEn but excluding .git
        local pattern="$1"
        shift
        grep -rEn --exclude-dir=.git --exclude-dir=dist "$pattern" "$@" 2>/dev/null || true
    }
fi

# 1. Closed-repo paths outside README.md + docs/ + scripts/lint-public.sh itself.
CLOSED_PATTERN='steloit/steloit-go|internal/cli|internal/audit|internal/billing|cmd/api|cmd/worker|cmd/mcp'
HITS=$(SEARCH "$CLOSED_PATTERN" \
    --glob '!README.md' \
    --glob '!docs/**' \
    --glob '!scripts/lint-public.sh' \
    --glob '!SECURITY.md' \
    --glob '!.github/workflows/release-skill.yml' \
    --glob '!CONTRIBUTING.md' \
    . 2>/dev/null || true)
# Strip lint-allow lines.
HITS=$(printf '%s\n' "$HITS" | grep -v 'lint-allow: closed-repo-ref' || true)
if [ -n "$HITS" ]; then
    fail "closed-repo path reference detected:"
    printf '%s\n' "$HITS" >&2
fi

# 2. INTERNAL / PROPRIETARY markers.
HITS=$(SEARCH 'INTERNAL_ONLY|PROPRIETARY|DO_NOT_RELEASE' \
    --glob '!scripts/lint-public.sh' \
    . 2>/dev/null || true)
if [ -n "$HITS" ]; then
    fail "proprietary marker detected:"
    printf '%s\n' "$HITS" >&2
fi

# 3. Credential patterns.
HITS=$(SEARCH '(sk_live_|sk_test_|whsec_|ghp_|github_pat_|AKIA[0-9A-Z]{16})' \
    --glob '!scripts/lint-public.sh' \
    . 2>/dev/null || true)
if [ -n "$HITS" ]; then
    fail "credential pattern detected:"
    printf '%s\n' "$HITS" >&2
fi

# 4. STELOIT_* env name allowlist.
ALLOWED_ENV='STELOIT_HOME|STELOIT_CONFIG|STELOIT_PROJECT|STELOIT_RUNTIME|STELOIT_PROVIDER|STELOIT_LOG_LEVEL'
HITS=$(SEARCH 'STELOIT_[A-Z_]+' \
    --glob '!scripts/lint-public.sh' \
    . 2>/dev/null || true)
# Filter to lines whose STELOIT_* token isn't in the allowlist.
BAD=$(printf '%s\n' "$HITS" | awk -v allowed="$ALLOWED_ENV" '
    {
        n = split($0, parts, /STELOIT_[A-Z_]+/);
        if (match($0, /STELOIT_[A-Z_]+/)) {
            tok = substr($0, RSTART, RLENGTH);
            if (allowed !~ tok) print;
        }
    }
' || true)
if [ -n "$BAD" ]; then
    fail "non-public STELOIT_* env name detected:"
    printf '%s\n' "$BAD" >&2
fi

# 5. LICENSE = Apache-2.0.
if ! grep -q "Apache License" LICENSE 2>/dev/null; then
    fail "LICENSE missing or not Apache-2.0"
fi

# 6. NOTICE present.
if [ ! -f NOTICE ]; then
    fail "NOTICE file missing"
fi

# 7. Apache headers on shell scripts.
for f in scripts/*.sh; do
    [ -f "$f" ] || continue
    if ! head -10 "$f" | grep -q "Apache License"; then
        fail "missing Apache header: $f"
    fi
done

if [ "$FAIL" -ne 0 ]; then
    exit 1
fi

echo "ok: lint-public.sh — clean"
