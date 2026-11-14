#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mkdir -p "$tmpdir/bin"
cat >"$tmpdir/bin/hyprctl" <<'FAKE'
#!/bin/bash
cat <<'JSON'
[
  {"mouse": false, "submap": "", "modmask": 72, "key": "SPACE", "description": "Apps"},
  {"mouse": false, "submap": "", "modmask": 64, "key": "K", "description": "Omarchy menu"},
  {"mouse": false, "submap": "", "modmask": 69, "key": "T", "description": "Theme menu"},
  {"mouse": false, "submap": "", "modmask": 0, "key": "XF86AudioMute", "description": "Mute"},
  {"mouse": true, "submap": "", "modmask": 64, "key": "mouse:272", "description": "Move window"},
  {"mouse": false, "submap": "resize", "modmask": 0, "key": "H", "description": "Shrink"}
]
JSON
FAKE
chmod +x "$tmpdir/bin/hyprctl"

bind_label() {
  PATH="$tmpdir/bin:$PATH" "$ROOT/bin/omarchy-hyprland-bind-label" "$@"
}

[[ $(bind_label Apps) == "SUPER ALT + SPACE" ]] || fail "the label names the keys bound to Apps" "$(bind_label Apps)"
[[ $(bind_label "Omarchy menu") == "SUPER + K" ]] || fail "an overridden binding reports its current keys"
[[ $(bind_label "Theme menu") == "SUPER CTRL SHIFT + T" ]] || fail "modifiers are named in order" "$(bind_label "Theme menu")"
[[ $(bind_label Mute) == "XF86AudioMute" ]] || fail "a binding without modifiers is just its key"
pass "bind label reports the key combination Hyprland has bound"

if bind_label "Move window" >/dev/null; then fail "mouse bindings are not reported"; fi
if bind_label Shrink >/dev/null; then fail "bindings inside a submap are not reported"; fi
if bind_label "No such binding" >/dev/null; then fail "an unknown description exits 1"; fi
pass "bind label exits 1 when nothing matches"

if bind_label >/dev/null 2>&1; then fail "a missing description is an error"; fi
pass "bind label requires a description"
