#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin" "$test_tmp/home"

cat >"$mock_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
exit 0
SH
cat >"$mock_bin/omarchy-theme-color" <<'SH'
#!/bin/bash
case $1 in
  background) printf '%s\n' "$REFRESH_COLOR" ;;
  foreground) printf '%s\n' '#ffffff' ;;
  accent) printf '%s\n' '#00aaff' ;;
  lighter_background) printf '%s\n' '#555555' ;;
esac
SH
cat >"$mock_bin/omarchy-theme-set-vivaldi" <<'SH'
#!/bin/bash
exit 0
SH
cat >"$mock_bin/hyprctl" <<'SH'
#!/bin/bash
# Pause the older refresh after it has read the palette, so the newer refresh
# runs entirely while the older one is still mid-flight.
if [[ ${REFRESH_ROLE:-} == older ]]; then
  : >"$REFRESH_PAUSED"
  while [[ ! -e $REFRESH_RELEASE ]]; do sleep 0.01; done
fi
case $3 in
  decoration:rounding) printf '{"int":0}\n' ;;
  decoration:active_opacity) printf '{"float":1.0,"set":false}\n' ;;
  *) printf '{"bool":false}\n' ;;
esac
SH
chmod +x "$mock_bin"/*

export REFRESH_PAUSED="$test_tmp/paused" REFRESH_RELEASE="$test_tmp/release"
channel="$test_tmp/channel/theme.json"
export VIVALDI_OMARCHY_JSON="$channel"

refresh() { # role color
  HOME="$test_tmp/home" OMARCHY_PATH="$ROOT" REFRESH_ROLE="$1" REFRESH_COLOR="$2" \
    PATH="$mock_bin:$ROOT/bin:$PATH" \
    bash "$ROOT/default/vivaldi/vivaldi-theme-refresh"
}

refresh older '#111111' &
older=$!
for _ in {1..300}; do
  [[ -e $REFRESH_PAUSED ]] && break
  sleep 0.01
done
[[ -e $REFRESH_PAUSED ]] || fail "the older refresh never reached its paused read"

refresh newer '#222222' &
newer=$!
sleep 0.5
: >"$REFRESH_RELEASE"

wait "$older" || fail "the older refresh failed"
wait "$newer" || fail "the newer refresh failed"

[[ $(jq -r '.colors.bg' "$channel") == "#222222" ]] ||
  fail "an older refresh overwrote the newer palette" \
    "got: $(jq -r '.colors.bg' "$channel")"
pass "a refresh that read the palette earlier cannot overwrite a newer refresh"
