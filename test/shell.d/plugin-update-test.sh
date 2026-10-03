#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

HOME_DIR="$TMPDIR/home"
PLUGIN_DIR="$HOME_DIR/.config/omarchy/plugins/acme.weather"
STUB_DIR="$TMPDIR/stubs"
mkdir -p "$PLUGIN_DIR/.git" "$STUB_DIR"
printf '%s\n' '{"id":"acme.weather","name":"Weather"}' >"$PLUGIN_DIR/manifest.json"

cat >"$STUB_DIR/git" <<'STUB'
#!/bin/bash
printf 'git %s\n' "$*" >>"$CALLS"
case "$3" in
fetch) exit 0 ;;
rev-parse)
  ref=${!#}
  if [[ $ref == "HEAD" ]]; then printf 'old\n'; else printf 'new\n'; fi
  ;;
diff)
  printf '%s\n' '-old setting' '+new setting'
  ;;
*) exit 0 ;;
esac
STUB

cat >"$STUB_DIR/gum" <<'STUB'
#!/bin/bash
printf 'gum %s\n' "$*" >>"$CALLS"
touch "$GUM_CALLED"
if [[ $1 == "choose" ]]; then printf '%s\n' "${GUM_CHOICE:-Show diff}"; fi
STUB

cat >"$STUB_DIR/omarchy-cmd-present" <<'STUB'
#!/bin/bash
exit 1
STUB

for command in omarchy-plugin-validate omarchy-shell; do
  cat >"$STUB_DIR/$command" <<'STUB'
#!/bin/bash
printf '%s %s\n' "${0##*/}" "$*" >>"$CALLS"
STUB
done

chmod +x "$STUB_DIR"/*

export CALLS="$TMPDIR/calls"
: >"$CALLS"

provider_script=$(node - "$ROOT/shell/plugins/menu/Menu.qml" <<'JS'
const fs = require('fs')
const qml = fs.readFileSync(process.argv[2], 'utf8')
const match = qml.match(/"plugin-updates": \{\s*script: ("(?:\\.|[^"\\])*")/)
if (!match) process.exit(1)
process.stdout.write(JSON.parse(match[1]))
JS
) || fail "plugin update provider script can be extracted from the menu"
provider_output=$(HOME="$HOME_DIR" PATH="$STUB_DIR:$PATH" bash -c "$provider_script")
expected_provider_output=$(printf 'Weather  old → new\tacme.weather\t')
[[ $provider_output == "$expected_provider_output" ]] ||
  fail "plugin update provider emits the available update row" "$provider_output"
pass "plugin update provider executes and emits the available update row"

status=0
output=$(HOME="$HOME_DIR" PATH="$STUB_DIR:$ROOT/bin:$PATH" GUM_CALLED="$TMPDIR/gum-called" \
  "$ROOT/bin/omarchy-plugin-update" acme.weather </dev/null 2>&1) || status=$?

(( status != 0 )) || fail "plugin update refuses noninteractive updates without --yes" "$output"
[[ $output == *"refusing to continue without confirmation; pass --yes"* ]] ||
  fail "plugin update explains how to confirm a noninteractive update" "$output"
[[ ! -e $TMPDIR/gum-called ]] || fail "plugin update opens gum without an interactive terminal"
pass "plugin update refuses noninteractive updates before opening gum"

: >"$CALLS"
rm -f "$TMPDIR/gum-called"
output=$(HOME="$HOME_DIR" PATH="$STUB_DIR:$ROOT/bin:$PATH" GUM_CALLED="$TMPDIR/gum-called" \
  "$ROOT/bin/omarchy-plugin-update" acme.weather --yes 2>&1) ||
  fail "plugin update rejects an explicitly confirmed noninteractive update" "$output"
[[ ! -e $TMPDIR/gum-called ]] || fail "plugin update opens gum when --yes was passed"
[[ $(<"$CALLS") == *"git -C $PLUGIN_DIR merge --ff-only FETCH_HEAD"* ]] ||
  fail "plugin update does not fast-forward after --yes" "$(<"$CALLS")"
[[ $(<"$CALLS") == *"omarchy-plugin-validate $PLUGIN_DIR"* ]] ||
  fail "plugin update does not validate after --yes" "$(<"$CALLS")"
[[ $(<"$CALLS") == *"omarchy-shell shell rescanPlugins"* ]] ||
  fail "plugin update does not rescan plugins after --yes" "$(<"$CALLS")"
pass "plugin update honors --yes without opening gum"

if script -qec true /dev/null >/dev/null 2>&1; then
  : >"$CALLS"
  rm -f "$TMPDIR/gum-called"
  status=0
  raw=$(HOME="$HOME_DIR" PATH="$STUB_DIR:$ROOT/bin:$PATH" CALLS="$CALLS" \
    GUM_CALLED="$TMPDIR/gum-called" GUM_CHOICE="Show diff" \
    script -qec "'$ROOT/bin/omarchy-plugin-update' acme.weather" /dev/null) || status=$?
  output=$(tr -d '\r' <<<"$raw")

  (( status == 0 )) || fail "interactive plugin update completes" "$output"
  [[ $output == *"Changes for acme.weather:"* && $output == *"+new setting"* ]] ||
    fail "interactive plugin update shows the requested diff" "$output"
  calls=$(<"$CALLS")
  [[ $calls == *"gum choose"*"review the diff first?"* ]] ||
    fail "interactive plugin update asks whether to review the diff" "$calls"
  [[ $calls == *"git -C $PLUGIN_DIR diff HEAD FETCH_HEAD"* ]] ||
    fail "interactive plugin update does not request the diff" "$calls"
  [[ $calls == *"gum confirm Update acme.weather?"* ]] ||
    fail "interactive plugin update does not ask for final confirmation" "$calls"
  [[ $calls == *"git -C $PLUGIN_DIR merge --ff-only FETCH_HEAD"* ]] ||
    fail "interactive plugin update does not fast-forward after confirmation" "$calls"
  pass "plugin update reviews and confirms an interactive update"

  : >"$CALLS"
  rm -f "$TMPDIR/gum-called"
  status=0
  raw=$(HOME="$HOME_DIR" PATH="$STUB_DIR:$ROOT/bin:$PATH" CALLS="$CALLS" \
    GUM_CALLED="$TMPDIR/gum-called" GUM_CHOICE="Update without diff" \
    script -qec "'$ROOT/bin/omarchy-plugin-update' acme.weather" /dev/null) || status=$?
  output=$(tr -d '\r' <<<"$raw")

  (( status == 0 )) || fail "interactive plugin update completes without a diff" "$output"
  calls=$(<"$CALLS")
  [[ $calls != *" diff HEAD FETCH_HEAD"* && $output != *"Changes for acme.weather:"* ]] ||
    fail "interactive plugin update shows a diff after it was declined" "$output"
  [[ $calls == *"gum confirm Update acme.weather?"*
    && $calls == *"git -C $PLUGIN_DIR merge --ff-only FETCH_HEAD"* ]] ||
    fail "interactive plugin update does not confirm and apply after skipping the diff" "$calls"
  pass "plugin update can skip the diff and still require confirmation"
else
  pass "script -qec unavailable; skipping the interactive plugin update case"
fi
