#!/usr/bin/env bash
# Copyright 2026 Steloit
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#     http://www.apache.org/licenses/LICENSE-2.0
#
# validate-frontmatter.sh — verify every SKILL.md has the required YAML
# frontmatter keys.

set -eu

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

python3 - <<'PY'
import os
import re
import sys

try:
    import yaml
except ImportError:
    sys.stderr.write("ERR: PyYAML not installed (pip install pyyaml)\n")
    sys.exit(2)

root = os.getcwd()
skills_dir = os.path.join(root, "skills")
if not os.path.isdir(skills_dir):
    sys.stderr.write(f"ERR: missing skills/ at {root}\n")
    sys.exit(1)

errors = []
seen_names = {}

# Load models.json once for model validation.
import json
with open(os.path.join(root, "models.json"), "r", encoding="utf-8") as f:
    models = json.load(f)
known_models = set()
for provider in models.get("providers", {}).values():
    for v in provider.values():
        known_models.add(v)

KNOWN_AGENTS = {
    "orchestrator", "planner", "critic", "builder", "shield",
    "inspector", "ranger", "refiner", "explorer", "sage", "reviewer",
}

NAME_RE = re.compile(r"^[a-z0-9-]+$")
FM_RE = re.compile(r"\A---\n(.*?)\n---\n(.*)\Z", re.DOTALL)

for entry in sorted(os.listdir(skills_dir)):
    skill_path = os.path.join(skills_dir, entry, "SKILL.md")
    if not os.path.isfile(skill_path):
        continue
    with open(skill_path, "r", encoding="utf-8") as f:
        text = f.read()
    m = FM_RE.match(text)
    if not m:
        errors.append(f"{skill_path}: missing YAML frontmatter")
        continue
    fm_text, body = m.group(1), m.group(2)
    try:
        fm = yaml.safe_load(fm_text)
    except yaml.YAMLError as e:
        errors.append(f"{skill_path}: invalid YAML — {e}")
        continue
    if not isinstance(fm, dict):
        errors.append(f"{skill_path}: frontmatter is not a mapping")
        continue

    name = fm.get("name")
    if not name or not isinstance(name, str):
        errors.append(f"{skill_path}: missing or non-string 'name'")
    elif not NAME_RE.match(name):
        errors.append(f"{skill_path}: name '{name}' fails regex [a-z0-9-]+")
    elif name != entry:
        errors.append(f"{skill_path}: name '{name}' != dir '{entry}'")
    else:
        if name in seen_names:
            errors.append(f"{skill_path}: duplicate name '{name}' (also in {seen_names[name]})")
        seen_names[name] = skill_path

    if not fm.get("description"):
        errors.append(f"{skill_path}: missing 'description'")

    # If model is declared, it must be a known model from models.json.
    model = fm.get("model")
    if model is not None and model not in known_models:
        errors.append(f"{skill_path}: model '{model}' not found in models.json")

    # If agent is declared (workflow skills), must be a known role.
    agent = fm.get("agent")
    if agent is not None and agent not in KNOWN_AGENTS:
        errors.append(f"{skill_path}: agent '{agent}' is not a known role")

    # Body must reference $ARGUMENTS (umbrella) or a TASK_ID/QUERY/PR placeholder (workflow).
    has_args = "$ARGUMENTS" in body
    has_placeholder = bool(re.search(r"<TASK_ID>|<QUERY>|<PR>|<QUESTION>", body))
    if not (has_args or has_placeholder):
        errors.append(f"{skill_path}: body has neither $ARGUMENTS nor <TASK_ID>-style placeholder")

if errors:
    for e in errors:
        sys.stderr.write(f"ERR: {e}\n")
    sys.exit(1)

print(f"ok: validate-frontmatter.sh — {len(seen_names)} skill(s) validated")
PY
