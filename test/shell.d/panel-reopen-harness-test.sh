#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

stage=$(mktemp -d)
trap 'rm -rf -- "$stage"' EXIT
mkdir -p "$stage/bin"
cat > "$stage/bin/grim" <<'SH'
#!/bin/bash
touch "$1"
SH
chmod +x "$stage/bin/grim"
selected=${1:-all}

run_case() {
  local name="$1" enabled="$2" flag="$3" config="$4" fault="$5" expected="$6" result=0
  [[ $selected == "all" || $selected == "$name" || ($selected == "cache" && $name == cache-*) ]] || return 0
  local work="$stage/$name"
  mkdir -p "$work/home/.config/omarchy" "$work/home/.local/state/omarchy/toggles/hypr" "$work/state" "$work/artifacts"
  printf '%s\n' "$enabled" > "$work/state/effective"
  printf '%s\n' "$enabled" > "$work/state/style"
  printf 'idle\n' > "$work/state/phase"
  printf 'false\n' > "$work/state/late"
  if [[ $config == "present" ]]; then printf '{"original":true}\n' > "$work/home/.config/omarchy/shell.json"; fi
  if [[ $flag == "present" ]]; then printf 'original animation flag\n' > "$work/home/.local/state/omarchy/toggles/hypr/no-animations.lua"; fi

  HOME="$work/home" PATH="$stage/bin:$PATH" OMARCHY_ACCEPTANCE_DIR="$work/artifacts" PANEL_TEST_STATE="$work/state" PANEL_TEST_FAULT="$fault" \
    bash -c 'source "$1/test/shell.d/fixtures/panel-acceptance-cli.sh"; bash "$1/test/acceptance.d/panel-reopen-test.sh"' bash "$ROOT" > "$work/output" 2>&1 || result=$?
  [[ $result == "$expected" ]] || fail "$name exits $expected" "exit=$result: $(cat "$work/output")"
  [[ $(cat "$work/state/effective") == "$enabled" ]] || fail "$name restores effective compositor animations"
  [[ $(cat "$work/state/style") == "$enabled" ]] || fail "$name restores the shell animation cache"
  local expected_fade=0
  [[ $enabled != "true" ]] || expected_fade=140
  jq -e --argjson expected "$expected_fade" '.fadeDuration == $expected' "$work/artifacts/panel-reopen-animations-restored.json" >/dev/null || fail "$name retains the verified shell animation setting"
  if [[ $fault != "restore-config" ]]; then
    if [[ $config == "present" ]]; then
      [[ $(cat "$work/home/.config/omarchy/shell.json") == '{"original":true}' ]] || fail "$name restores shell configuration"
    else
      [[ ! -e $work/home/.config/omarchy/shell.json ]] || fail "$name restores absent shell configuration"
    fi
  fi
  if [[ $flag == "present" ]]; then
    [[ $(cat "$work/home/.local/state/omarchy/toggles/hypr/no-animations.lua") == 'original animation flag' ]] || fail "$name restores exact animation flag"
  else
    [[ ! -e $work/home/.local/state/omarchy/toggles/hypr/no-animations.lua ]] || fail "$name restores absent animation flag"
  fi
  if [[ $fault != "remove-plugin" ]]; then
    [[ ! -e $work/home/.config/omarchy/plugins/acceptance.panel-reopen ]] || fail "$name removes its plugin"
  fi
  if [[ -n $fault ]]; then
    local recovery
    recovery=$(find "$work/artifacts" -type d -name 'panel-reopen-recovery.*' -print -quit)
    [[ -n $recovery ]] || fail "$name retains recovery preimages"
    [[ $(cat "$recovery/config.json") == '{"original":true}' ]] || fail "$name preserves the original configuration backup"
    awk '/^fault / { failed=1 } failed && /^omarchy-shell shell rescanPlugins$/ { continued=1 } END { exit !continued }' "$work/state/calls" || fail "$name continues cleanup after a failed command"
  else
    [[ -z $(find "$work/artifacts" -type d -name 'panel-reopen-recovery.*' -print -quit) ]] || fail "$name removes unneeded recovery backups"
  fi
  pass "$name"
}

run_case runtime-override false absent present '' 0
run_case animations-disabled false present present '' 0
run_case animations-enabled true absent present '' 0
run_case absent-config true absent absent '' 0
run_case plugin-removal-error false present present remove-plugin 1
run_case config-restoration-error true absent present restore-config 1
run_case animation-directory-error false present present restore-animation-directory 1

# A new component URL is necessary even when the same fixture is repeated in
# one shell: Qt may otherwise retain the component from a previous source copy.
entries=()
if [[ $selected == "all" || $selected == "cache" ]]; then
  for i in 1 2; do
    run_case "cache-$i" true absent present '' 0
    entries+=("$(cat "$stage/cache-$i/state/entrypoints")")
    [[ ${entries[i-1]} == */PanelReopen.qml ]] || fail "fixture preserves its QML type name in a fresh directory"
  done
  [[ ${entries[0]} != "${entries[1]}" ]] || fail "each fixture load gets a distinct QML URL"
  pass "each fixture load gets a distinct QML URL"
fi
