#!/usr/bin/env bash
# regenerate the ldoc api docs into a scratch dir and fail if they differ from
# the committed docs/ tree. the public site (telegram-bot-lua.hesketh.pro) is an
# nginx vhost whose root is this repo's docs/ directory, so committed docs ARE
# the live site -- this guard stops src/ and the published docs drifting apart.
#
# ldoc stamps a per-page "last updated" timestamp, so that one line is
# normalised away before comparing; any other difference is treated as drift.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

command -v ldoc >/dev/null 2>&1 || {
    echo "error: ldoc not found on PATH (luarocks install ldoc)" >&2
    exit 2
}

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

ldoc -d "$tmp" . >/dev/null

# blank out ldoc's per-page timestamp so it does not count as drift
norm() {
    sed -E 's/Last updated [0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}/Last updated TIMESTAMP/g' "$1"
}

drift=0

# every file ldoc generates must exist under docs/ and match it
while IFS= read -r gen; do
    rel="${gen#"$tmp"/}"
    committed="docs/$rel"
    if [ ! -f "$committed" ]; then
        echo "drift: docs/$rel is missing" >&2
        drift=1
        continue
    fi
    if ! diff -u <(norm "$committed") <(norm "$gen") >/dev/null; then
        echo "drift: docs/$rel is out of date" >&2
        diff -u <(norm "$committed") <(norm "$gen") | head -40 >&2 || true
        drift=1
    fi
done < <(find "$tmp" -type f | sort)

# committed html that ldoc no longer emits (e.g. a removed module) is stale
while IFS= read -r committed; do
    rel="${committed#docs/}"
    if [ ! -f "$tmp/$rel" ]; then
        echo "drift: $committed is stale -- ldoc no longer generates it" >&2
        drift=1
    fi
done < <(find docs/modules docs/topics -type f -name '*.html' 2>/dev/null | sort)

if [ "$drift" -ne 0 ]; then
    echo >&2
    echo "docs/ is out of sync with src/. run 'make docs' and commit the result." >&2
    exit 1
fi

echo "docs/ is in sync with src/."
