#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command lua
require_command jq

output=$(lua "$ROOT/test/shell.d/fixtures/keybindings/registry.lua" "$ROOT") || fail "live binding registry behavior"
printf '%s\n' "$output" | grep '^ok -'
snapshot=$(sed -n 's/^SNAPSHOT://p' <<<"$output")
jq -e '.bindings | length == 3' <<<"$snapshot" >/dev/null || fail "registry emits valid JSON"
jq -e '.bindings[0].description == "comma, tab\tquote\" backslash\\\nUnicode →"' <<<"$snapshot" >/dev/null || fail "JSON metadata round-trips without corruption"
pass "binding metadata survives JSON serialization"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/bin"
cat >"$tmpdir/bin/hyprctl" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"$CALLS"
STUB
chmod +x "$tmpdir/bin/hyprctl"
for i in 1 2; do
  CALLS="$tmpdir/calls" PATH="$tmpdir/bin:$PATH" HYPRLAND_INSTANCE_SIGNATURE=test \
    bash -euo pipefail "$ROOT/migrations/1789328800.sh" >/dev/null
done
[[ $(cat "$tmpdir/calls") == $'reload\nreload' ]] || fail "migration only reloads the existing session"
rm "$tmpdir/calls"
CALLS="$tmpdir/calls" PATH="$tmpdir/bin:$PATH" HYPRLAND_INSTANCE_SIGNATURE= \
  bash -euo pipefail "$ROOT/migrations/1789328800.sh" >/dev/null
[[ ! -e $tmpdir/calls ]] || fail "offline upgrade must wait for next login"
pass "migration is repeatable and leaves offline upgrades for next login"
