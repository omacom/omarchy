#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

mkdir -p "$tmp/bin"
preview_file="$tmp/example.txt"
preview_file_with_space="$tmp/has space.txt"
preview_dir="$tmp/example-dir"
printf 'hello\n' >"$preview_file"
printf 'hello\n' >"$preview_file_with_space"
mkdir -p "$preview_dir"

cat >"$tmp/bin/file" <<'SH'
#!/bin/bash
printf 'text/plain\n'
SH
chmod +x "$tmp/bin/file"

cat >"$tmp/bin/sushi" <<'SH'
#!/bin/bash
printf 'sushi:%s\n' "$*" >"$OMARCHY_PREVIEW_LOG"
SH
chmod +x "$tmp/bin/sushi"

OMARCHY_PREVIEW_LOG="$tmp/log" PATH="$tmp/bin" "$ROOT/bin/omarchy-preview" "$preview_file"
[[ $(<"$tmp/log") == "sushi:$preview_file" ]] ||
  fail "preview uses Sushi when available"
pass "preview uses Sushi when available"

OMARCHY_PREVIEW_LOG="$tmp/log" PATH="$tmp/bin" "$ROOT/bin/omarchy-preview" "$preview_file_with_space"
[[ $(<"$tmp/log") == "sushi:$preview_file_with_space" ]] ||
  fail "preview preserves paths with spaces for Sushi"
pass "preview preserves paths with spaces for Sushi"

rm -f "$tmp/bin/sushi" "$tmp/log"
cat >"$tmp/bin/gio" <<'SH'
#!/bin/bash
printf 'gio:%s\n' "$*" >"$OMARCHY_PREVIEW_LOG"
SH
chmod +x "$tmp/bin/gio"

OMARCHY_PREVIEW_LOG="$tmp/log" PATH="$tmp/bin" "$ROOT/bin/omarchy-preview" "$preview_file"
[[ $(<"$tmp/log") == "gio:open $preview_file" ]] ||
  fail "preview falls back to gio open"
pass "preview falls back to gio open"

OMARCHY_PREVIEW_LOG="$tmp/log" PATH="$tmp/bin" "$ROOT/bin/omarchy-preview" "$preview_file_with_space"
[[ $(<"$tmp/log") == "gio:open $preview_file_with_space" ]] ||
  fail "preview preserves paths with spaces for gio"
pass "preview preserves paths with spaces for gio"

if PATH="$tmp/bin" "$ROOT/bin/omarchy-preview" "$preview_file" "$tmp/other" 2>"$tmp/error"; then
  fail "preview rejects extra paths"
fi
grep -q "expected one path, got 2" "$tmp/error" ||
  fail "preview reports extra paths"
pass "preview rejects extra paths"

rm -f "$tmp/bin/gio"
if PATH="$tmp/bin" "$ROOT/bin/omarchy-preview" "$preview_dir" 2>"$tmp/error"; then
  fail "preview reports missing directory openers"
fi
grep -q "no preview application found for $preview_dir" "$tmp/error" ||
  fail "preview reports missing directory openers"
pass "preview reports missing directory openers"

if "$ROOT/bin/omarchy-preview" "$tmp/missing" 2>"$tmp/error"; then
  fail "preview rejects missing paths"
fi
grep -q "not found: $tmp/missing" "$tmp/error" ||
  fail "preview reports missing path"
pass "preview rejects missing paths"
