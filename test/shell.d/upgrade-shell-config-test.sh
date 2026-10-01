#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
upgrade="$ROOT/bin/omarchy-upgrade-to-quattro"

eval "$(awk '/^copy_missing_config_defaults\(\) \{/ { copying=1 } copying { print } copying && /^\}$/ { exit }' "$upgrade")"
eval "$(awk '/^validate_shell_config\(\) \{/ { copying=1 } copying { print } copying && /^\}$/ { exit }' "$upgrade")"
is_retired_config_file() { return 1; }
run_as_user() { "$@"; }
apply_user_transition() { copy_missing_config_defaults "$test_tmp/defaults" "$target_home/.config"; }
apply_user_hardware_transition() { :; }
run_as_user_omarchy() {
  if [[ $1 == "omarchy-bar" ]]; then
    bar_reset=1
    [[ ${BAR_RESULT:-0} == "0" ]] || return 1
    HOME="$target_home" OMARCHY_PATH="$ROOT" PATH="$test_tmp/bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-bar" defaults >/dev/null
  fi
}
warn() { printf '%s\n' "$*" >"$test_tmp/warning"; }
transition=$(awk '/^bar_defaults_pending=/ { copying=1 } /^cleanup_retired_services$/ { exit } copying { print }' "$upgrade")
[[ -n $transition ]] || fail "user transition is found"
always_copy=$(awk '/^always_copy_config_files=\(/ { copying=1 } copying { print } copying && /^\)$/ { exit }' "$upgrade")
[[ $always_copy != *omarchy/shell.json* ]] || fail "shell settings are not forcibly replaced"

mkdir -p "$test_tmp/defaults/omarchy" "$test_tmp/bin"
cp "$ROOT/config/omarchy/shell.json" "$test_tmp/defaults/omarchy/shell.json"
for command in omarchy-shell omarchy-agent-usage-update omarchy-pkg-drop omarchy-installed-service-dropbox omarchy-installed-service-tailscale; do
  printf '#!/bin/bash\nexit 0\n' >"$test_tmp/bin/$command"
  chmod +x "$test_tmp/bin/$command"
done

for scenario in fresh retry custom symlink invalid dangling; do
  target_home="$test_tmp/$scenario"
  mkdir -p "$target_home/.config/omarchy"
  settings="$target_home/.config/omarchy/shell.json"
  case "$scenario" in
    custom|symlink)
      printf '%s\n' '{"plugins":["local.example"],"idle":{"lock":600},"bar":{"transparent":true,"layout":{"right":[{"id":"omacom.elsewhen","cities":["Tokyo"]}]}}}' >"$settings"
      if [[ $scenario == "symlink" ]]; then
        mv "$settings" "$target_home/settings.json"
        ln -s "$target_home/settings.json" "$settings"
      fi
      ;;
    invalid) printf '%s\n' 'unfinished user edit' >"$settings" ;;
    dangling) ln -s "$target_home/missing.json" "$settings" ;;
  esac
  before=$(readlink "$settings" || { [[ ! -f $settings ]] || sha256sum "$settings"; })
  if [[ $scenario == "invalid" || $scenario == "dangling" ]]; then
    if (validate_shell_config) >"$test_tmp/validation-error" 2>&1; then
      fail "$scenario settings must stop the upgrade before system mutation"
    fi
    after=$(readlink "$settings" || sha256sum "$settings")
    [[ $before == "$after" ]] || fail "preflight preserves settings that need repair"
    grep -q 'Repair' "$test_tmp/validation-error" || fail "preflight explains what to repair"
    pass "$scenario settings stop in preflight without changing the user's file"
    continue
  fi
  validate_shell_config
  bar_reset=0
  if [[ $scenario == "retry" ]]; then
    # Interrupt immediately after the transition copied the packaged settings.
    eval "${transition%%apply_user_hardware_transition*}"
    [[ -f $bar_defaults_pending && -f $settings ]] || fail "fresh initialization is recorded before later steps"
    bar_reset=0
    BAR_RESULT=1 eval "$transition"
    [[ -f $bar_defaults_pending ]] || fail "failed bar initialization remains pending"
    bar_reset=0
  fi
  eval "$transition"
  if [[ $scenario == "fresh" || $scenario == "retry" ]]; then
    (( bar_reset == 1 )) || fail "fresh and interrupted upgrades initialize the bar"
    jq -e '[.bar.layout[] | .[] | .id] | index("omarchy.dropbox") != null and index("omarchy.tailscale") != null' "$settings" >/dev/null || fail "installed-service widgets are initialized"
    [[ ! -e $bar_defaults_pending ]] || fail "successful initialization clears the pending marker"
  else
    (( bar_reset == 0 )) || fail "existing settings avoid the default bar reset"
    after=$(readlink "$settings" || sha256sum "$settings")
    [[ $before == "$after" ]] || fail "existing settings survive the transition"
    for migration in 1780294774 1784989000 1785344985 1786099804 1790042972 1790528634; do
      HOME="$target_home" OMARCHY_PATH="$ROOT" PATH="$test_tmp/bin:$ROOT/bin:$PATH" bash -euo pipefail "$ROOT/migrations/$migration.sh" >/dev/null
    done
    jq -e '.idle.lock == 600 and .bar.transparent and (.plugins | index("local.example") != null) and ([.bar.layout[]? | .[]? | select(type == "object" and .id == "omarchy.elsewhen") | .cities] | any(. == ["Tokyo"]))' "$settings" >/dev/null || fail "migrations preserve custom settings while updating legacy widgets"
    if [[ $scenario == "symlink" ]]; then
      [[ -L $settings && $(readlink "$settings") == "$before" ]] || fail "pending migrations retain the dotfiles symlink"
    fi
  fi
  pass "$scenario settings retain user preferences through the real bar and migration writes"
done
