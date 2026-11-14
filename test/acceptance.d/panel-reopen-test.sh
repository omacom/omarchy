#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/panel-keyboard-context.sh"

plugin=acceptance.panel-reopen
plugin_dir="$HOME/.config/omarchy/plugins/$plugin"
config="$HOME/.config/omarchy/shell.json"
animation_flag="$HOME/.local/state/omarchy/toggles/hypr/no-animations.lua"
config_existed=0
animation_flag_existed=0
plugin_created=0
plugin_enabled=0
animations_changed=0
animation_before=$(hyprctl -j getoption animations:enabled | jq -er '.bool | tostring')
[[ $animation_before == "true" || $animation_before == "false" ]] || fail "animation state can be recorded"
[[ ! -e $plugin_dir && ! -L $plugin_dir ]] || fail "acceptance fixture does not replace an existing plugin"
assert_panel_keyboard_context
recovery=$(mktemp -d "$ARTIFACTS/panel-reopen-recovery.XXXXXX")
if [[ -f $config ]]; then cp "$config" "$recovery/config.json"; config_existed=1; fi
if [[ -f $animation_flag ]]; then cp "$animation_flag" "$recovery/no-animations.lua"; animation_flag_existed=1; fi

restore_shell_animations() {
  local deadline=$((SECONDS + 15)) expected=0
  [[ $animation_before != "true" ]] || expected=140
  # A reload's old asynchronous query must finish before starting a new one
  # against the restored runtime override. Runtime overrides emit no reload.
  until [[ $(omarchy-shell "$plugin" refreshStyle 2>/dev/null) == "true" ]]; do
    ((SECONDS < deadline)) || return 1
    sleep 0.1
  done
  until omarchy-shell "$plugin" state > "$ARTIFACTS/panel-reopen-animations-restored.json" 2> "$ARTIFACTS/panel-reopen-animations-restored.stderr" \
    && jq -e --argjson expected "$expected" '.fadeDuration == $expected' "$ARTIFACTS/panel-reopen-animations-restored.json" >/dev/null; do
    ((SECONDS < deadline)) || return 1
    sleep 0.1
  done
}

cleanup() {
  local status=$? cleanup_failed=0
  trap - EXIT
  if ((animations_changed)); then
    if ((animation_flag_existed)); then
      mkdir -p "$(dirname "$animation_flag")" || cleanup_failed=1
      cp "$recovery/no-animations.lua" "$animation_flag" || cleanup_failed=1
    else
      rm -f "$animation_flag" || cleanup_failed=1
    fi
    hyprctl reload >/dev/null 2>&1 || cleanup_failed=1
    hyprctl eval "hl.config({ animations = { enabled = $animation_before } })" >/dev/null 2>&1 || cleanup_failed=1
    [[ $(hyprctl -j getoption animations:enabled | jq -r .bool) == "$animation_before" ]] || cleanup_failed=1
    restore_shell_animations || cleanup_failed=1
  fi
  if ((plugin_enabled)); then
    omarchy-shell shell hide "$plugin" >/dev/null 2>&1 || cleanup_failed=1
    omarchy-shell shell setPluginEnabled "$plugin" false >/dev/null 2>&1 || cleanup_failed=1
  fi
  if ((config_existed)); then
    cp "$recovery/config.json" "$config" || cleanup_failed=1
  else
    rm -f "$config" || cleanup_failed=1
  fi
  if ((plugin_created)); then
    rm -rf -- "$plugin_dir" || cleanup_failed=1
    omarchy-shell shell rescanPlugins >/dev/null 2>&1 || cleanup_failed=1
    omarchy-shell shell reloadConfig >/dev/null 2>&1 || cleanup_failed=1
  fi
  if ((cleanup_failed == 0)); then
    rm -rf -- "$recovery" || cleanup_failed=1
  fi
  if ((cleanup_failed)); then
    printf 'not ok - fade fixture cleanup failed; recovery preimages retained at %s\n' "$recovery" >&2
    status=1
  fi
  exit "$status"
}
trap cleanup EXIT

mkdir -p "$(dirname "$plugin_dir")"
mkdir "$plugin_dir"
plugin_created=1
# Qt can cache a removed component by URL. Each run needs its own entry point
# so edits are tested without restarting the whole desktop shell.
entrypoint="run${recovery##*.}/PanelReopen.qml"
mkdir "$plugin_dir/${entrypoint%/*}"
cp "$ROOT/test/acceptance.d/fixtures/panel-reopen/PanelReopen.qml" "$plugin_dir/$entrypoint"
jq --arg entrypoint "$entrypoint" '.entryPoints.overlay = $entrypoint' \
  "$ROOT/test/acceptance.d/fixtures/panel-reopen/manifest.json" > "$plugin_dir/manifest.json"
cp "$plugin_dir/manifest.json" "$ARTIFACTS/panel-reopen-fixture-manifest.json"
sha256sum "$plugin_dir/$entrypoint" > "$ARTIFACTS/panel-reopen-fixture.sha256"
omarchy-shell shell rescanPlugins >/dev/null
plugin_discovered() {
  omarchy-shell shell listPlugins | jq -e --arg id "$plugin" 'any(.[]; .id == $id)'
}
wait_until "fade fixture plugin is discovered" 15 plugin_discovered
plugin_enabled=1
[[ $(omarchy-shell shell setPluginEnabled "$plugin" true) == "ok" ]] || fail "fade fixture plugin enables"
animations_changed=1
omarchy-toggle-animations on >/dev/null
positive_fade() {
  omarchy-shell "$plugin" state | jq -e '.fadeDuration > 0'
}
wait_until "fade fixture has a positive duration" 15 positive_fade

trial_finished() {
  local delay="$1"
  omarchy-shell "$plugin" state > "$ARTIFACTS/fade-$delay.json" || return 1
  jq -e '.phase == "done" or .phase == "failed"' "$ARTIFACTS/fade-$delay.json"
}
trial_ready() {
  local delay="$1"
  omarchy-shell "$plugin" state > "$ARTIFACTS/fade-$delay-ready.json" || return 1
  jq -e '.phase == "ready" or .phase == "failed"' "$ARTIFACTS/fade-$delay-ready.json"
}
for delay in 1 110; do
  assert_panel_keyboard_context omarchy-acceptance-anchor
  wait_until "previous panel fully unmaps" 15 layer_absent omarchy-keyboard-panel
  omarchy-shell shell summon "$plugin" "{\"escapeDelay\":$delay}" >/dev/null
  wait_until "initial panel is ready ($delay ms launch)" 15 trial_ready "$delay"
  jq -e '.phase == "ready"' "$ARTIFACTS/fade-$delay-ready.json" >/dev/null || fail "initial fade fixture opens" "$(cat "$ARTIFACTS/fade-$delay-ready.json")"
  screenshot "success-panel-fade-before-$delay"
  assert_panel_keyboard_context omarchy-acceptance-anchor
  [[ $(omarchy-shell "$plugin" begin) == "true" ]] || fail "measured fade trial starts"
  wait_until "fade-reopen trial completes ($delay ms launch)" 15 trial_finished "$delay"
  jq -e --argjson late "$([[ $delay == 110 ]] && echo true || echo false)" '
    .phase == "done" and .error == "" and .fadeDuration > 0 and .retainedMapping
    and .activationLost and .activationGained and .windowActiveAtEscape
    and .escapeCount == 1 and .targetFocusedAtEscape and (.mapped | not) and (.open | not)
    and .primedAtEscape == $late
  ' "$ARTIFACTS/fade-$delay.json" >/dev/null || fail "single Escape closes a mapped fade reopen across the focus-prime boundary" "$(cat "$ARTIFACTS/fade-$delay.json")"
  screenshot "success-panel-fade-reopen-$delay"
  pass "real fade reopen closes with one Escape ($delay ms launch)"
done
