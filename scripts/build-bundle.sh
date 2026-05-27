#!/usr/bin/env bash
# Copyright 2026 Humane Technologies Inc.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#     http://www.apache.org/licenses/LICENSE-2.0
#
# build-bundle.sh — produce skill-bundle-v<ver>.tar.zst locally, in
# exact parity with the CI release pipeline. Used by devs to reproduce
# what GitHub Actions ships.
#
# Usage: scripts/build-bundle.sh <version>

set -eu

if [ "$#" -ne 1 ]; then
    echo "usage: $0 <version>" >&2
    echo "       e.g. $0 0.1.0" >&2
    exit 2
fi

VERSION="$1"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

mkdir -p dist
TARBALL="dist/skill-bundle-v${VERSION}.tar.zst"

# Pack: skills dir, models.json, LICENSE, NOTICE, README, TRADEMARK.
# Exclude everything else (CI, scripts, docs, CHANGELOG, CONTRIBUTING).
tar --zstd \
    -cf "$TARBALL" \
    LICENSE \
    NOTICE \
    README.md \
    TRADEMARK.md \
    models.json \
    skills

sha256sum "$TARBALL" > dist/sha256sums.txt 2>/dev/null \
    || shasum -a 256 "$TARBALL" > dist/sha256sums.txt

echo "ok: built $TARBALL"
echo "    sha256: $(awk '{print $1}' dist/sha256sums.txt)"
