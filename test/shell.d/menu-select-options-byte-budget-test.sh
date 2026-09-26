#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

stub="$tmp/bin"
mkdir -p "$stub"

cat >"$stub/omarchy-shell" <<'STUB'
#!/bin/bash
echo "omarchy-shell should not be reached for oversized options" >&2
exit 99
STUB
chmod +x "$stub/omarchy-shell"

# 80 options x ~2000 invalid bytes each → encoded JSON well over 120KB via U+FFFD
opts=()
i=1
while [[ $i -le 80 ]]; do
  name=$(python3 -c 'import sys; sys.stdout.buffer.write(b"n%03d-"%int(sys.argv[1])+b"\xff"*2000)' "$i")
  opts+=("$name")
  i=$((i + 1))
done

set +e
err=$(
  LC_ALL=C.UTF-8 PATH="$stub:$PATH" \
    "$ROOT/bin/omarchy-menu-select" "Pick" "${opts[@]}" 2>&1
)
rc=$?
set -e

[[ $rc -eq 1 ]] || fail "menu-select rejects oversized options under UTF-8 (exit $rc)" "$err"
[[ $err == *"options payload too large"* ]] || fail "menu-select oversized error message" "$err"
pass "menu-select rejects oversized encoded options by byte length under UTF-8"

cat >"$stub/omarchy-shell" <<'STUB'
#!/bin/bash
payload="$4"
done=$(printf '%s' "$payload" | perl -MJSON::PP=decode_json -e 'print decode_json(do { local $/; <STDIN> })->{doneFile}')
: >"$done"
exit 0
STUB
chmod +x "$stub/omarchy-shell"

set +e
out=$(LC_ALL=C.UTF-8 PATH="$stub:$PATH" "$ROOT/bin/omarchy-menu-select" "Pick" "a" "b" 2>&1)
rc=$?
set -e
[[ $out != *"options payload too large"* ]] || fail "small menu should not hit byte budget" "$out"
[[ $rc -eq 1 ]] || fail "small menu empty selection exits 1" "status=$rc out=$out"
pass "menu-select small options pass byte budget under UTF-8"
