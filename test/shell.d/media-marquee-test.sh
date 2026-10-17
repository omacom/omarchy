#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=""
QS_PID=""

cleanup() {
  if [[ -n $QS_PID ]] && kill -0 "$QS_PID" 2>/dev/null; then
    kill "$QS_PID" 2>/dev/null || true
    wait "$QS_PID" 2>/dev/null || true
  fi
  if [[ -n $TMPDIR && -d $TMPDIR ]]; then
    rm -rf "$TMPDIR"
  fi
}
trap cleanup EXIT

require_compositor "media marquee test"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell not installed; skipping media marquee test"
  exit 0
fi

require_command jq

TMPDIR=$(mktemp -d)
result="$TMPDIR/result.json"
log="$TMPDIR/quickshell.log"
config_dir="$TMPDIR/media-marquee"
mkdir -p "$config_dir" "$TMPDIR/home" "$TMPDIR/bin"
cp "$SHELL_TEST_DIR/fixtures/media-marquee/shell.qml" "$config_dir/shell.qml"
ln -s "$ROOT/shell/Ui" "$config_dir/Ui"
ln -s "$ROOT/shell/Commons" "$config_dir/Commons"

# Style asks Hyprland whether animations are on and would stop the marquee on a
# desktop that has them off, as a VM does by default.
real_hyprctl=$(command -v hyprctl || true)
cat >"$TMPDIR/bin/hyprctl" <<SH
#!/bin/bash
[[ \$* == "-j getoption animations:enabled" ]] && { printf '{"bool":true}\n'; exit 0; }
[[ -n "$real_hyprctl" ]] && exec "$real_hyprctl" "\$@"
exit 1
SH
chmod +x "$TMPDIR/bin/hyprctl"

OMARCHY_PATH="$ROOT" \
OMARCHY_QML_TEST_RESULT="$result" \
OMARCHY_QML_MEDIA_WIDGET="file://$ROOT/shell/plugins/services/media/BarWidget.qml" \
HOME="$TMPDIR/home" \
XDG_CONFIG_HOME="$TMPDIR/home/.config" \
XDG_CACHE_HOME="$TMPDIR/home/.cache" \
XDG_STATE_HOME="$TMPDIR/home/.local/state" \
QML2_IMPORT_PATH="$ROOT/shell${QML2_IMPORT_PATH:+:$QML2_IMPORT_PATH}" \
QML_IMPORT_PATH="$ROOT/shell${QML_IMPORT_PATH:+:$QML_IMPORT_PATH}" \
PATH="$TMPDIR/bin:$ROOT/bin:$PATH" \
  quickshell -p "$config_dir" --no-color >"$log" 2>&1 &
QS_PID=$!

for _ in {1..100}; do
  [[ -s $result ]] && break
  if ! kill -0 "$QS_PID" 2>/dev/null; then
    sed -n '1,220p' "$log" >&2
    fail "media marquee quickshell exited before writing result"
  fi
  sleep 0.1
done

[[ -s $result ]] || {
  sed -n '1,220p' "$log" >&2
  fail "media marquee test timed out"
}

if ! jq -e '.ok == true' "$result" >/dev/null; then
  jq . "$result" >&2
  sed -n '1,220p' "$log" >&2
  fail "the media marquee scrolls only while the player is playing"
fi

pass "the media marquee scrolls only while the player is playing"
