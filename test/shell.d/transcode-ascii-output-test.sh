#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin" "$test_tmp/scratch" "$test_tmp/directory"
touch "$test_tmp/input.png" "$test_tmp/blocked-parent"
cat >"$test_tmp/bin/magick" <<'SH'
#!/bin/bash
if [[ ${!#} == "info:" ]]; then
  echo '0 1'
else
  printf 'P1\n2 2\n1 1\n1 1\n'
fi
SH
chmod +x "$test_tmp/bin/magick"
export PATH="$test_tmp/bin:$PATH" TMPDIR="$test_tmp/scratch"

for output in "$test_tmp/blocked-parent/art.txt" "$test_tmp/directory"; do
  if bash "$ROOT/bin/omarchy-transcode-ascii" "$test_tmp/input.png" "$output" --mode block >"$test_tmp/output" 2>"$test_tmp/errors"; then
    fail "ASCII export rejects an unwritable output path" "$output"
  fi
  if grep -q 'Wrote ASCII art' "$test_tmp/output"; then
    fail "failed ASCII export does not announce success"
  fi
  [[ -z $(find "$test_tmp/scratch" "$test_tmp/directory" -type f -print -quit) ]] || fail "failed export leaves no temporary output"
done
pass "ASCII export fails on invalid destinations without reporting success"

bash "$ROOT/bin/omarchy-transcode-ascii" "$test_tmp/input.png" "$test_tmp/nested/art.txt" --mode block >"$test_tmp/output"
[[ -s $test_tmp/nested/art.txt ]] || fail "ASCII export creates the requested output"
grep -q 'Wrote ASCII art' "$test_tmp/output" || fail "successful ASCII export reports its destination"
[[ -z $(find "$test_tmp/scratch" -type f -print -quit) ]] || fail "successful export cleans up temporary output"
pass "ASCII export still creates missing parent directories and writes output"
