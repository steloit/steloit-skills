#!/usr/bin/env bash
# validate-template.sh — validate a steloit template (.md) against contract/v1/.
#
# Usage: scripts/validate-template.sh <template.md> [<template.md> ...]
# Exit:  0 = all valid; 1 = at least one invalid (errors on stderr).
#
# Requires: python3, jsonschema>=4.20, PyYAML>=6.0
#   (pip install -r scripts/requirements.txt)

set -eu

if [ "$#" -lt 1 ]; then
  echo "usage: $0 <template.md> [<template.md> ...]" >&2
  exit 2
fi

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONTRACT_DIR="${REPO_ROOT}/contract/v1"

export STELOIT_CONTRACT_DIR="${CONTRACT_DIR}"
export STELOIT_REPO_ROOT="${REPO_ROOT}"

python3 - "$@" <<'PY'
import json
import os
import re
import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    sys.stderr.write("ERROR: PyYAML not installed. Run: pip install -r scripts/requirements.txt\n")
    sys.exit(2)

try:
    from jsonschema import Draft202012Validator
except ImportError:
    sys.stderr.write("ERROR: jsonschema not installed. Run: pip install -r scripts/requirements.txt\n")
    sys.exit(2)

CONTRACT = Path(os.environ["STELOIT_CONTRACT_DIR"])
REPO_ROOT = Path(os.environ["STELOIT_REPO_ROOT"])

placeholders_schema = json.loads((CONTRACT / "placeholders.schema.json").read_text())
frontmatter_schema = json.loads((CONTRACT / "frontmatter.schema.json").read_text())
rubric_schema = json.loads((CONTRACT / "rubric.schema.json").read_text())

ALLOWED_PLACEHOLDERS = set(placeholders_schema["enum"])

SIGNATURE_RE = re.compile(
    r"^> \*\*[A-Z][a-z]+\*\* `[a-z0-9.\-]+` · "
    r"[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$"
)

FM_RE = re.compile(r"^---\s*\n(.*?)\n---\s*\n(.*)\Z", re.DOTALL)

PLACEHOLDER_RE = re.compile(r"<([A-Z][A-Z0-9_]*)>")


def fail(path, ptr, msg):
    sys.stderr.write(f"INVALID {path}: {ptr}: {msg}\n")


def validate(path: Path) -> bool:
    text = path.read_text()
    m = FM_RE.match(text)
    if not m:
        fail(path, "/", "no YAML frontmatter fence (--- ... ---) at start of file")
        return False
    fm_raw, body = m.group(1), m.group(2)

    try:
        fm = yaml.safe_load(fm_raw)
    except yaml.YAMLError as e:
        fail(path, "/frontmatter", f"YAML parse error: {e}")
        return False
    if not isinstance(fm, dict):
        fail(path, "/frontmatter", "frontmatter must be a YAML mapping")
        return False

    ok = True
    v = Draft202012Validator(frontmatter_schema)
    for err in sorted(v.iter_errors(fm), key=lambda e: list(e.absolute_path)):
        ptr = "/" + "/".join(str(p) for p in err.absolute_path) if err.absolute_path else "/"
        fail(path, ptr, err.message)
        ok = False

    # Signature header: first non-blank line of body must match SIGNATURE_RE.
    sig_line = None
    for line in body.splitlines():
        if line.strip():
            sig_line = line
            break
    if sig_line is None or not SIGNATURE_RE.match(sig_line):
        fail(path, "/body/signature", "first non-blank body line must match signature regex")
        ok = False

    # Placeholder sweep.
    for ph in PLACEHOLDER_RE.findall(body):
        if ph not in ALLOWED_PLACEHOLDERS:
            fail(path, "/body/placeholders", f"unknown placeholder <{ph}> (not in contract/v1/placeholders.schema.json enum)")
            ok = False

    # Rubric resolution.
    rubric_ref = fm.get("rubric_ref")
    if rubric_ref:
        rubric_path = path.parent / "rubrics" / f"{rubric_ref}.yaml"
        if not rubric_path.exists():
            fail(path, "/frontmatter/rubric_ref", f"rubric file not found: {rubric_path}")
            ok = False
        else:
            try:
                rub = yaml.safe_load(rubric_path.read_text())
            except yaml.YAMLError as e:
                fail(path, "/frontmatter/rubric_ref", f"rubric YAML parse error: {e}")
                return False
            rv = Draft202012Validator(rubric_schema)
            for err in sorted(rv.iter_errors(rub), key=lambda e: list(e.absolute_path)):
                ptr = "/rubric/" + "/".join(str(p) for p in err.absolute_path) if err.absolute_path else "/rubric"
                fail(path, ptr, err.message)
                ok = False

    if ok:
        sys.stdout.write(f"OK {path}\n")
    return ok


rc = 0
for arg in sys.argv[1:]:
    p = Path(arg)
    if not p.exists():
        sys.stderr.write(f"INVALID {arg}: file not found\n")
        rc = 1
        continue
    if not validate(p):
        rc = 1

sys.exit(rc)
PY
