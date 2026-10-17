#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
export HOME="$test_tmp/home" XDG_CONFIG_HOME="$test_tmp/home/.config"
mkdir -p "$test_tmp/bin" "$HOME/dotfiles" "$HOME/.vscode/extensions" "$XDG_CONFIG_HOME/omarchy/defaults" "$XDG_CONFIG_HOME/systemd/user"
export PATH="$test_tmp/bin:$PATH"

# Load only the repair functions: running the upgrade would mutate the host.
load_function() {
  local file="$1" name="$2"
  eval "$(awk -v name="$name" '$0 == name "() {" { inside = 1 } inside { print } inside && $0 == "}" { exit }' "$file")"
}
load_function "$ROOT/bin/omarchy-theme-set-vscode" rewrite_extension_registry
load_function "$ROOT/bin/omarchy-theme-set-vscode" register_generated_extension
load_function "$ROOT/bin/omarchy-upgrade-to-quattro" repair_sleep_lock_unit_override
load_function "$ROOT/bin/omarchy-upgrade-to-quattro" backup_config_file
BACKUP_SUFFIX=test
GENERATED_EXTENSION_ID=local.omarchy-theme
GENERATED_EXTENSION_VERSION=1.0.0
ext_base="$HOME/.vscode/extensions"
ext_dir="$ext_base/omarchy-theme"
registry="$ext_base/extensions.json"
obsolete="$ext_base/.obsolete"
config="$XDG_CONFIG_HOME/omarchy/defaults/dictation"
unit="$XDG_CONFIG_HOME/systemd/user/omarchy-sleep-lock.service"
legacy_exec='ExecStart=%h/.local/share/omarchy/bin/omarchy-system-sleep-monitor'
current_exec='ExecStart=/usr/bin/omarchy-system-sleep-monitor'

cat >"$test_tmp/bin/omarchy-default-dictation" <<'SH'
#!/bin/bash
cat "$XDG_CONFIG_HOME/omarchy/defaults/dictation" 2>/dev/null
SH
cat >"$test_tmp/bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
exit 1
SH
chmod +x "$test_tmp/bin/"*

assert_mode() {
  [[ $(stat -Lc '%a' -- "$1") == "$2" ]] || fail "$3 preserves mode $2"
}
assert_no_temps() {
  local temporary
  for temporary in "$1".??????; do
    [[ ! -e $temporary ]] || fail "rewrite cleans its temporary file: $temporary"
  done
}
write_unit() {
  printf '[Service]\n%s\n# user override\n' "$legacy_exec" >"$unit"
}

for mode in 644 600 664; do
  printf '[{"identifier":{"id":"other.extension"}}]\n' >"$registry"
  printf '{"local.omarchy-theme-1.0.0":true,"other.extension-1.0.0":true}\n' >"$obsolete"
  chmod "$mode" "$registry" "$obsolete"
  register_generated_extension "$ext_dir"
  assert_mode "$registry" "$mode" 'VS Code registry'
  assert_mode "$obsolete" "$mode" 'VS Code obsolete registry'
  jq -e 'length == 2 and .[0].identifier.id == "other.extension" and .[1].identifier.id == "local.omarchy-theme"' "$registry" >/dev/null || fail "registry retains other extensions"
  jq -e '. == {"other.extension-1.0.0":true}' "$obsolete" >/dev/null || fail "obsolete registry retains other extensions"
  before=$(cat "$registry")
  register_generated_extension "$ext_dir"
  [[ $(cat "$registry") == "$before" ]] || fail "registry rewrite is idempotent"

  printf 'old-backend\n' >"$config"
  chmod "$mode" "$config"
  "$ROOT/bin/omarchy-dictation-use" new-backend
  assert_mode "$config" "$mode" dictation
  [[ $(cat "$config") == "new-backend" ]] || fail "dictation saves the selected backend"
  "$ROOT/bin/omarchy-dictation-use" new-backend
  assert_mode "$config" "$mode" dictation

  write_unit
  chmod "$mode" "$unit"
  repair_sleep_lock_unit_override
  assert_mode "$unit" "$mode" 'sleep lock unit'
  grep -qxF "$current_exec" "$unit" || fail "sleep lock command is repaired"
  grep -qxF '# user override' "$unit" || fail "sleep lock customizations survive"
  before=$(cat "$unit")
  repair_sleep_lock_unit_override
  [[ $(cat "$unit") == "$before" ]] || fail "sleep lock repair is idempotent"
done
pass "config rewrites preserve public, private, and group writable modes and are idempotent"

rm "$registry" "$obsolete" "$config" "$unit"
printf '[]\n' >"$HOME/dotfiles/extensions.json"
printf '{"local.omarchy-theme-1.0.0":true}\n' >"$HOME/dotfiles/obsolete"
printf 'old-backend\n' >"$HOME/dotfiles/dictation"
printf '[Service]\n%s\n' "$legacy_exec" >"$HOME/dotfiles/sleep-lock.service"
chmod 640 "$HOME/dotfiles/"*
ln -s ../../dotfiles/extensions.json "$registry"
ln -s ../../dotfiles/obsolete "$obsolete"
ln -s ../../../dotfiles/dictation "$config"
ln -s ../../../dotfiles/sleep-lock.service "$unit"
register_generated_extension "$ext_dir"
"$ROOT/bin/omarchy-dictation-use" new-backend
unit_target=$(readlink -f -- "$unit")
unit_before=$(cat "$unit_target")
repair_sleep_lock_unit_override
unit_backup="$unit_target.omarchy-upgrade-to-quattro.$BACKUP_SUFFIX.bak"
[[ -f $unit_backup && ! -L $unit_backup ]] || fail "sleep lock backup snapshots the resolved file"
[[ $(cat "$unit_backup") == "$unit_before" ]] || fail "sleep lock backup retains the original contents"
assert_mode "$unit_backup" 640 'sleep lock backup'
repair_sleep_lock_unit_override
[[ $(cat "$unit_backup") == "$unit_before" ]] || fail "repeated repair preserves the original backup"
pass "sleep lock repair retains a snapshot of the original symlink referent"
for file in "$registry" "$obsolete" "$config" "$unit"; do
  [[ -L $file && -f $file ]] || fail "config rewrite retains a live relative symlink: $file"
  assert_mode "$file" 640 'symlink referent'
  assert_no_temps "$(readlink -f -- "$file")"
done
[[ $(readlink "$registry") == '../../dotfiles/extensions.json' && $(readlink "$obsolete") == '../../dotfiles/obsolete' ]] || fail "VS Code symlink destinations are unchanged"
[[ $(readlink "$config") == '../../../dotfiles/dictation' && $(readlink "$unit") == '../../../dotfiles/sleep-lock.service' ]] || fail "dictation and unit symlink destinations are unchanged"
jq -e '. == {}' "$HOME/dotfiles/obsolete" >/dev/null || fail "an empty symlinked obsolete registry retains its referent"
[[ $(cat "$HOME/dotfiles/dictation") == "new-backend" ]] || fail "dictation updates the symlink referent"
grep -qxF "$current_exec" "$HOME/dotfiles/sleep-lock.service" || fail "sleep lock repair updates the symlink referent"
register_generated_extension "$ext_dir"
[[ -L $obsolete && -f $obsolete ]] || fail "empty obsolete symlink remains valid on repeated rewrites"
pass "config rewrites update relative symlink referents without removing empty obsolete registries"

# A regular empty obsolete registry still follows VS Code's removal convention.
rm "$obsolete"
printf '{"local.omarchy-theme-1.0.0":true}\n' >"$obsolete"
register_generated_extension "$ext_dir"
[[ ! -e $obsolete ]] || fail "empty regular obsolete registries are removed"
pass "empty regular obsolete registry cleanup is preserved"

for kind in registry obsolete dictation unit; do
  case "$kind" in
    registry) file="$registry"; printf '[]\n' >"$file" ;;
    obsolete) file="$obsolete"; printf '{"local.omarchy-theme-1.0.0":true}\n' >"$file" ;;
    dictation) file="$config"; printf 'old-backend\n' >"$file" ;;
    unit) file="$unit"; write_unit ;;
  esac
  chmod 444 "$file"
  before=$(cat "$file")
  if case "$kind" in
    registry|obsolete) register_generated_extension "$ext_dir" ;;
    dictation) "$ROOT/bin/omarchy-dictation-use" new-backend ;;
    unit) repair_sleep_lock_unit_override ;;
  esac >"$test_tmp/error" 2>&1; then
    fail "$kind refuses a deliberately read-only target"
  fi
  [[ $(cat "$file") == "$before" ]] || fail "$kind preserves a read-only target's contents"
  assert_mode "$file" 444 "$kind"
  assert_no_temps "$(readlink -f -- "$file")"
  chmod 640 "$file"
done
pass "config rewrites refuse deliberately read-only targets even when run as root"

# Invalid source data must not replace a working file or leave a staged rewrite.
for file in "$registry" "$obsolete"; do
  printf 'invalid json\n' >"$file"
  if register_generated_extension "$ext_dir" >"$test_tmp/error" 2>&1; then
    fail "invalid VS Code registry data returns a failure"
  fi
  [[ $(cat "$file") == 'invalid json' ]] || fail "invalid registry is retained for recovery"
  assert_no_temps "$(readlink -f -- "$file")"
  printf '{}\n' >"$obsolete"
  printf '[]\n' >"$registry"
done
before=$(cat "$config")
if "$ROOT/bin/omarchy-dictation-use" '../invalid' >"$test_tmp/error" 2>&1; then
  fail "invalid backend selection returns a failure"
fi
[[ $(cat "$config") == "$before" ]] || fail "invalid backend selection preserves the previous value"
pass "invalid inputs leave existing config contents intact"

# A generated-registry failure reaches the command's caller and prevents later
# editor syncs, while toggles that skip all editors still succeed.
mkdir -p "$HOME/.local/state/omarchy/current/theme"
printf '{"colors":{}}\n' >"$HOME/.local/state/omarchy/current/theme/vscode-theme.json"
printf 'invalid json\n' >"$registry"
export EDITOR_PROBES="$test_tmp/editor-probes"
cat >"$test_tmp/bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
printf '%s\n' "$1" >>"$EDITOR_PROBES"
SH
cat >"$test_tmp/bin/omarchy-toggle-enabled" <<'SH'
#!/bin/bash
[[ ${SKIP_EDITORS:-0} == 1 ]]
SH
chmod +x "$test_tmp/bin/omarchy-cmd-present" "$test_tmp/bin/omarchy-toggle-enabled"
if "$ROOT/bin/omarchy-theme-set-vscode" >"$test_tmp/error" 2>&1; then
  fail "theme command returns generated-registry errors"
fi
[[ $(cat "$EDITOR_PROBES") == 'code' ]] || fail "registry failure prevents subsequent editor syncs"
SKIP_EDITORS=1 "$ROOT/bin/omarchy-theme-set-vscode"
[[ $(cat "$EDITOR_PROBES") == 'code' ]] || fail "enabled skip toggles prevent editor probes"
cat >"$test_tmp/bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
exit 1
SH
printf '[]\n' >"$registry"
pass "theme command propagates registry failures and preserves successful skip toggles"

# Stubs fail after partial output or before publication; every error must survive
# cleanup. They also assert that staging happens beside the resolved target.
export FAIL_COMMAND='' STAGING_LOG="$test_tmp/staging"
for command in jq awk chmod mv mktemp; do
  real_command=$(command -v "$command")
  cat >"$test_tmp/bin/$command" <<SH
#!/bin/bash
if [[ \${FAIL_COMMAND:-} == '${command}' ]]; then
  printf 'partial transform\\n'
  exit 73
fi
if [[ '${command}' == 'mktemp' ]]; then
  printf '%s\\n' "\$1" >>"\$STAGING_LOG"
fi
exec '$real_command' "\$@"
SH
  chmod +x "$test_tmp/bin/$command"
done
hash -r
for kind in registry dictation unit; do
  case "$kind" in
    registry) file="$registry"; failures='jq chmod mv mktemp' ;;
    dictation) file="$config"; failures='chmod mv mktemp' ;;
    unit) file="$unit"; failures='awk chmod mv mktemp' ;;
  esac
  for command in $failures; do
    case "$kind" in
      registry) printf '[]\n' >"$file"; rm -f "$obsolete" ;;
      dictation) printf 'old-backend\n' >"$file" ;;
      unit) write_unit ;;
    esac
    before=$(cat "$file")
    export FAIL_COMMAND="$command"
    status=0
    case "$kind" in
      registry) register_generated_extension "$ext_dir" >"$test_tmp/error" 2>&1 || status=$? ;;
      dictation) "$ROOT/bin/omarchy-dictation-use" new-backend >"$test_tmp/error" 2>&1 || status=$? ;;
      unit) repair_sleep_lock_unit_override >"$test_tmp/error" 2>&1 || status=$? ;;
    esac
    export FAIL_COMMAND=''
    [[ $status == 73 ]] || fail "$kind preserves the $command failure status (got $status)"
    [[ $(cat "$file") == "$before" ]] || fail "$kind retains existing config after $command failure"
    assert_mode "$file" 640 "$kind after $command failure"
    assert_no_temps "$(readlink -f -- "$file")"
  done
done
while IFS= read -r template; do
  [[ $template == "$HOME/dotfiles/"* ]] || fail "temporary files are staged beside the resolved config: $template"
done <"$STAGING_LOG"
pass "transform, chmod, publish, and staging failures preserve status and clean temporary files"

rm "$registry" "$config"
register_generated_extension "$ext_dir"
"$ROOT/bin/omarchy-dictation-use" new-backend
assert_mode "$registry" 600 'new VS Code registry'
assert_mode "$config" 600 'new dictation config'
pass "new registry and dictation configs keep their existing private default mode"
