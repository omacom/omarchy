#!/bin/bash

set -uo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

test_tmp=$(mktemp -d)
[[ -n $test_tmp && -d $test_tmp ]] ||
  fail "the test creates its own scratch directory before touching anything"
secret="$test_tmp/secret"
trap 'chmod 0600 "$secret" 2>/dev/null || true; rm -rf -- "$test_tmp"' EXIT

plymouth_theme_assets=(
  bullet.png
  entry.png
  lock.png
  logo.png
  omarchy.plymouth
  omarchy.script
  preview-unlock.png
  progress_bar.png
  progress_box.png
)
plymouth_default_assets=("${plymouth_theme_assets[@]}" logos/oma.png)
plymouth_custom_assets=("${plymouth_theme_assets[@]/#omarchy.plymouth/omarchy-custom.plymouth}")
sddm_theme_assets=(Main.qml bullet.png entry-failed.png entry.png lock-failed.png lock.png logo.png)
sddm_default_assets=("${sddm_theme_assets[@]}" metadata.desktop theme.conf)

# Keep the refresh allowlist synchronized with every packaged Plymouth asset.
# An added default file must make this test fail until its publication contract
# is explicitly reviewed and included above.
packaged_plymouth_assets=$(find "$ROOT/default/plymouth" -type f -printf '%P\n' | LC_ALL=C sort)
allowlisted_plymouth_assets=$(printf '%s\n' "${plymouth_default_assets[@]}" | LC_ALL=C sort)
[[ $packaged_plymouth_assets == "$allowlisted_plymouth_assets" ]] ||
  fail "Plymouth refresh allowlist differs from the packaged asset set" "$packaged_plymouth_assets"
pass "Plymouth refresh allowlist covers every packaged asset"

# SDDM reset is also a fixed-file publication contract. New packaged files
# must fail this test until their trust and reset behavior are reviewed.
packaged_sddm_assets=$(find "$ROOT/default/sddm/omarchy" -type f -printf '%P\n' | LC_ALL=C sort)
allowlisted_sddm_assets=$(printf '%s\n' "${sddm_default_assets[@]}" | LC_ALL=C sort)
[[ $packaged_sddm_assets == "$allowlisted_sddm_assets" ]] ||
  fail "SDDM refresh allowlist differs from the packaged asset set" "$packaged_sddm_assets"
pass "SDDM refresh allowlist covers every packaged asset"

# omarchy-plymouth-set-by-theme hands over a theme's unlock.png from
# ~/.config/omarchy/themes. Both installed copies are world-readable, so a
# symlink there must not republish whatever it points at.
printf 'not yours\n' >"$secret"
ln -s "$secret" "$test_tmp/logo-link.png"

output=$(OMARCHY_PATH="$ROOT" /bin/bash "$ROOT/bin/omarchy-plymouth-set" '#1d2021' '#ebdbb2' "$test_tmp/logo-link.png" 2>&1)
status=$?

(( status != 0 )) || fail "omarchy-plymouth-set refuses a symlinked logo"
[[ $output == *"symlink"* ]] || fail "omarchy-plymouth-set says why it refused the logo" "$output"

pass "a themed logo cannot republish a file it merely points at"

# The descriptor must be opened before elevation. Invoking the whole command
# as root would make the pre-open race privileged again, so refuse that shape
# before sudo or any publication can begin. User namespaces let this run
# without real privilege; retain a structural assertion on hosts that disable
# them so the invariant never becomes an untested skip.
if unshare --user --map-root-user true 2>/dev/null; then
  output=$(unshare --user --map-root-user env OMARCHY_PATH="$ROOT" /bin/bash "$ROOT/bin/omarchy-plymouth-set" '#1d2021' '#ebdbb2' "$secret" 2>&1)
  status=$?
  (( status != 0 )) || fail "omarchy-plymouth-set refuses to run as root"
  [[ $output == *"as your user"* && $output == *"not under sudo"* ]] ||
    fail "the root refusal explains how to invoke the publisher safely" "$output"
else
  grep -A2 -Eq '^if \(\( EUID == 0 \)\); then$' "$ROOT/bin/omarchy-plymouth-set" ||
    fail "omarchy-plymouth-set retains its root-invocation guard"
fi
pass "the logo descriptor can only be opened by an unprivileged caller"

# Appearance > Unlock picks a theme by name and hands the answer to
# omarchy-launch-floating-terminal-with-presentation, which joins its arguments
# into a script and runs that with `bash -c`. So the name is shell source
# unless the action quotes it -- and the name is a directory name under
# ~/.config/omarchy/themes, which a theme installed from a git repo gets from
# the repo URL. `a';id;'b` is a legal directory name.
require_command node

unlock_action=$(node -e '
  const fs = require("fs")
  const path = require("path")
  const menu = require(path.join(process.env.ROOT, "shell/plugins/menu/MenuModel.js"))
  const items = menu.parseMenuJsonc(fs.readFileSync(path.join(process.env.ROOT, "default/omarchy/omarchy-menu.jsonc"), "utf8"))
  process.stdout.write(items.find(item => item.id === "appearance.unlock").action)
')

[[ -n $unlock_action ]] || fail "the shipped menu still carries a appearance.unlock action"

stub_dir="$test_tmp/stubs"
mkdir -p "$stub_dir"

canary="$test_tmp/canary"
set_args="$test_tmp/set-args"
reset_marker="$test_tmp/reset-ran"

# What a name that got reparsed would reach. It is a command rather than a
# `touch` so that no quoting of the test's own paths is involved.
cat >"$stub_dir/omarchy-test-canary" <<STUB
#!/bin/bash
printf 'ran\n' >"$canary"
STUB

cat >"$stub_dir/omarchy-plymouth-switcher" <<'STUB'
#!/bin/bash
printf '%s\n' "$OMARCHY_TEST_UNLOCK_NAME"
STUB

# Run the real presentation wrapper while replacing only its terminal launcher.
# The launcher stub executes the final `bash -c` locally instead of opening a
# terminal window.
ln -s "$ROOT/bin/omarchy-launch-floating-terminal-with-presentation" "$stub_dir/omarchy-launch-floating-terminal-with-presentation"

cat >"$stub_dir/omarchy-restart-gum" <<'STUB'
#!/bin/bash
:
STUB

cat >"$stub_dir/setsid" <<'STUB'
#!/bin/bash
while (( $# >= 3 )); do
  if [[ $1 == "bash" && $2 == "-c" ]]; then
    exec bash -c "$3"
  fi
  shift
done
exit 97
STUB

# Records what actually arrived, so a name that survived as data is told apart
# from one that arrived split or partly eaten.
cat >"$stub_dir/omarchy-plymouth-set-by-theme" <<'STUB'
#!/bin/bash
printf '%s\n' "$#" "$@" >"$OMARCHY_TEST_SET_ARGS"
STUB

cat >"$stub_dir/omarchy-plymouth-reset" <<'STUB'
#!/bin/bash
printf 'ran\n' >"$OMARCHY_TEST_RESET_MARKER"
STUB

for command in omarchy-show-logo omarchy-show-done; do
  printf '#!/bin/bash\nexit 0\n' >"$stub_dir/$command"
done

chmod +x "$stub_dir"/*

run_unlock_action() {
  rm -f "$canary" "$set_args" "$reset_marker"

  PATH="$stub_dir:$PATH" \
    OMARCHY_TEST_UNLOCK_NAME="$1" \
    OMARCHY_TEST_SET_ARGS="$set_args" \
    OMARCHY_TEST_RESET_MARKER="$reset_marker" \
    bash -c "$unlock_action" >/dev/null 2>&1
}

# A directory name cannot hold a slash or a NUL, and everything else is fair
# game -- these are the shapes that would run on the way to the picker.
for name in "a';omarchy-test-canary;'b" 'a$(omarchy-test-canary)b' 'a`omarchy-test-canary`b' 'a b' '-a'; do
  run_unlock_action "$name"

  [[ ! -e $canary ]] || fail "a theme name reaches the unlock screen as data, not as shell" "ran for: $name"
  [[ $(cat "$set_args" 2>/dev/null) == $'1\n'"$name" ]] ||
    fail "the unlock screen gets the theme name whole" "$name: $(cat "$set_args" 2>/dev/null)"
done

pass "a theme name cannot carry a command into the unlock screen"

# The two ordinary paths still work: a named theme is applied, and `default`
# resets rather than being looked up as a theme.
run_unlock_action "tokyo-night"
[[ $(cat "$set_args" 2>/dev/null) == $'1\ntokyo-night' ]] ||
  fail "an ordinary theme name still reaches omarchy-plymouth-set-by-theme" "$(cat "$set_args" 2>/dev/null)"

run_unlock_action "default"
[[ -e $reset_marker ]] || fail "picking default still resets the unlock screen"
[[ ! -e $set_args ]] || fail "picking default does not look up a theme named default" "$(cat "$set_args")"

pass "the unlock picker still applies a theme and still resets on default"

fake_bin="$test_tmp/bin"
root_tools="$test_tmp/root-tools"
stages="$test_tmp/stages"
mkdir -p "$fake_bin" "$root_tools" "$stages"

cat >"$fake_bin/sudo" <<'SH'
#!/bin/bash
set -u

for argument in "$@"; do
  if [[ $argument == *"$TEST_STAGES"* ]]; then
    printf '%s\n' "$argument" >>"$TEST_LEAK_LOG"
  fi
done

case "$1" in
/bin/bash)
  [[ ${2:-} == -c && $# == 9 ]] || exit 90
  code=$3
  shell_name=$4
  shift 4
  printf 'root transaction\n' >>"$TEST_SUDO_LOG"

  # The production helper intentionally resets PATH. For this unprivileged
  # simulation only, substitute trusted tools and map fixed system destinations
  # under the disposable fake root.
  code=${code/PATH=\/usr\/bin:\/bin/PATH=$TEST_ROOT_TOOLS:\/usr\/bin:\/bin}
  code=${code/omarchy_conf=\/etc\/omarchy.conf/omarchy_conf=$TEST_OMARCHY_CONF}
  code=${code/theme_dir=\/usr\/share\/plymouth\/themes\/omarchy/theme_dir=$TEST_FAKE_ROOT\/usr\/share\/plymouth\/themes\/omarchy}
  code=${code/sddm_dir=\/usr\/share\/sddm\/themes\/omarchy/sddm_dir=$TEST_FAKE_ROOT\/usr\/share\/sddm\/themes\/omarchy}
  code=${code/plymouth_custom_dir=\/usr\/share\/plymouth\/themes\/omarchy-custom/plymouth_custom_dir=$TEST_FAKE_ROOT\/usr\/share\/plymouth\/themes\/omarchy-custom}
  code=${code/sddm_custom_dir=\/usr\/share\/sddm\/themes\/omarchy-custom/sddm_custom_dir=$TEST_FAKE_ROOT\/usr\/share\/sddm\/themes\/omarchy-custom}
  code=${code/sddm_conf_dir=\/etc\/sddm.conf.d/sddm_conf_dir=$TEST_FAKE_ROOT\/etc\/sddm.conf.d}

  # Each rewrite above silently no-ops if the production text drifts, which
  # would point this simulation at the real /usr/share. Refuse instead.
  [[ $code == *"PATH=$TEST_ROOT_TOOLS:/usr/bin:/bin"* ]] || exit 94
  [[ $code == *"omarchy_conf=$TEST_OMARCHY_CONF"* ]] || exit 94
  [[ $code == *"theme_dir=$TEST_FAKE_ROOT/usr/share/plymouth/themes/omarchy"* ]] || exit 94
  [[ $code == *"sddm_dir=$TEST_FAKE_ROOT/usr/share/sddm/themes/omarchy"* ]] || exit 94
  [[ $code == *"plymouth_custom_dir=$TEST_FAKE_ROOT/usr/share/plymouth/themes/omarchy-custom"* ]] || exit 94
  [[ $code == *"sddm_custom_dir=$TEST_FAKE_ROOT/usr/share/sddm/themes/omarchy-custom"* ]] || exit 94
  [[ $code == *"sddm_conf_dir=$TEST_FAKE_ROOT/etc/sddm.conf.d"* ]] || exit 94

  PATH="$TEST_ROOT_TOOLS:/usr/bin:/bin" \
    /bin/bash -c "$code" "$shell_name" "$@"
  ;;
plymouth-set-default-theme | limine-mkinitcpio | mkinitcpio)
  printf 'command %s\n' "$*" >>"$TEST_SUDO_LOG"
  exit 0
  ;;
*)
  echo "unexpected sudo command: $*" >&2
  exit 92
  ;;
esac
SH

cat >"$root_tools/stat" <<'SH'
#!/bin/bash
last=${!#}
if [[ ${1:-} == -c && ${2:-} == %u ]]; then
  if [[ (-n ${TEST_UNTRUSTED_SOURCE:-} && $last == "$TEST_UNTRUSTED_SOURCE"*) ||
        (-n ${TEST_UNTRUSTED_CONFIGURATION:-} && $last == "$TEST_UNTRUSTED_CONFIGURATION"*) ]]; then
    printf '1000\n'
    exit 0
  fi
  printf '0\n'
  exit 0
fi
if [[ ${1:-} == -c && ${2:-} == %a && $last == /tmp ]]; then
  printf '755\n'
  exit 0
fi
exec /usr/bin/stat "$@"
SH

cat >"$root_tools/chown" <<'SH'
#!/bin/bash
last=${!#}
[[ $last == "$TEST_FAKE_ROOT"* || $last == /tmp/omarchy-plymouth.* ]] || exit 93
exit 0
SH

cat >"$root_tools/install" <<'SH'
#!/bin/bash
mode=
while (( $# )); do
  case "$1" in
  -o | -g)
    shift 2
    ;;
  -m)
    mode=$2
    shift 2
    ;;
  --)
    shift
    break
    ;;
  *)
    exit 96
    ;;
  esac
done

(( $# == 2 )) || exit 96
[[ $mode == "0600" || $mode == "0644" ]] || exit 96
destination=$2
[[ $destination == "$TEST_FAKE_ROOT"* || $destination == /tmp/omarchy-plymouth.* ]] || exit 93
exec /usr/bin/install -m "$mode" -- "$1" "$destination"
SH

cat >"$root_tools/magick" <<'SH'
#!/bin/bash
source=$1
destination=${@: -1}
[[ $source == "$destination" ]] || /usr/bin/cp -- "$source" "$destination"
SH

cat >"$fake_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
exit 1
SH

chmod +x "$fake_bin"/* "$root_tools"/*

printf 'caller-selected logo\n' >"$test_tmp/logo.png"

setup_run() {
  run_dir=$(mktemp -d "$test_tmp/run.XXXXXXXX")
  fake_root="$run_dir/root"
  sudo_log="$run_dir/sudo.log"
  leak_log="$run_dir/leaked-stage-path.log"
  omarchy_conf="$run_dir/omarchy.conf"
  theme="$fake_root/usr/share/plymouth/themes/omarchy"
  sddm="$fake_root/usr/share/sddm/themes/omarchy"
  custom_theme="$fake_root/usr/share/plymouth/themes/omarchy-custom"
  custom_sddm="$fake_root/usr/share/sddm/themes/omarchy-custom"
  sddm_conf="$fake_root/etc/sddm.conf.d"
  custom_conf="$sddm_conf/20-omarchy-custom-theme.conf"

  mkdir -p "$theme/logos" "$sddm" "$sddm_conf"
  chmod 0755 \
    "$fake_root/etc" \
    "$sddm_conf" \
    "$fake_root/usr" \
    "$fake_root/usr/share" \
    "$fake_root/usr/share/plymouth" \
    "$fake_root/usr/share/plymouth/themes" \
    "$theme" \
    "$theme/logos" \
    "$fake_root/usr/share/sddm" \
    "$fake_root/usr/share/sddm/themes" \
    "$sddm"

  local asset destination
  for asset in "${plymouth_default_assets[@]}"; do
    destination="$theme/$asset"
    printf 'old plymouth %s\n' "$asset" >"$destination"
    chmod 0600 "$destination"
  done
  for asset in "${sddm_default_assets[@]}"; do
    destination="$sddm/$asset"
    printf 'old sddm %s\n' "$asset" >"$destination"
    chmod 0600 "$destination"
  done

  plymouth_victim="$run_dir/plymouth-victim"
  sddm_victim="$run_dir/sddm-victim"
  legacy_victim="$run_dir/legacy-victim"
  printf 'PLYMOUTH VICTIM\n' >"$plymouth_victim"
  printf 'SDDM VICTIM\n' >"$sddm_victim"
  printf 'LEGACY VICTIM\n' >"$legacy_victim"
  chmod 0600 "$plymouth_victim" "$sddm_victim" "$legacy_victim"

  rm -f "$theme/omarchy.script" "$sddm/Main.qml"
  ln -s "$plymouth_victim" "$theme/omarchy.script"
  ln -s "$sddm_victim" "$sddm/Main.qml"
  ln -s "$legacy_victim" "$sddm/logo.svg"
}

setup_fresh_run() {
  local asset destination

  setup_run
  for asset in "${plymouth_default_assets[@]}"; do
    destination="$theme/$asset"
    rm -f -- "$destination"
    /usr/bin/install -m 0644 -- "$ROOT/default/plymouth/$asset" "$destination"
  done
  for asset in "${sddm_default_assets[@]}"; do
    destination="$sddm/$asset"
    rm -f -- "$destination"
    /usr/bin/install -m 0644 -- "$ROOT/default/sddm/omarchy/$asset" "$destination"
  done
  rm -f -- "$sddm/logo.svg"
}

run_in_fake_root() {
  local requested_umask="$1"
  shift
  (
    umask "$requested_umask"
    PATH="$fake_bin:$ROOT/bin:$PATH" \
      TMPDIR="$stages" \
      OMARCHY_PATH="$ROOT" \
      TEST_FAKE_ROOT="$fake_root" \
      TEST_STAGES="$stages" \
      TEST_ROOT_TOOLS="$root_tools" \
      TEST_OMARCHY_CONF="$omarchy_conf" \
      TEST_SUDO_LOG="$sudo_log" \
      TEST_LEAK_LOG="$leak_log" \
      "$@"
  )
}

run_set_colors() {
  local requested_umask="$1" background="$2" text="$3"
  shift 3
  run_in_fake_root "$requested_umask" "$@" \
    /bin/bash "$ROOT/bin/omarchy-plymouth-set" "$background" "$text" "$test_tmp/logo.png"
}

run_set() {
  local requested_umask="$1"
  shift
  run_set_colors "$requested_umask" '#1d2021' '#ebdbb2' "$@"
}

run_refresh_plymouth() {
  run_in_fake_root 022 "$@" /bin/bash "$ROOT/bin/omarchy-refresh-plymouth"
}

run_refresh_sddm() {
  run_in_fake_root 022 "$@" /bin/bash "$ROOT/bin/omarchy-refresh-sddm"
}

run_reset() {
  run_in_fake_root 022 "$@" /bin/bash "$ROOT/bin/omarchy-plymouth-reset"
}

assert_no_temporary_files() {
  local directory="$1" leftovers
  leftovers=$(find "$directory" -name '.*.omarchy-new.*' -print)
  [[ -z $leftovers ]] || fail "failed publication cleans up its root-side temporary file" "$leftovers"
}

assert_packaged_assets() {
  local context=$1 source_dir=$2 destination_dir=$3
  shift 3

  local asset destination
  for asset in "$@"; do
    destination="$destination_dir/$asset"
    cmp -s "$source_dir/$asset" "$destination" || fail "$context publishes the packaged $asset bytes"
    [[ -f $destination && ! -L $destination && $(stat -c %a "$destination") == 644 ]] ||
      fail "$context publishes $asset as a regular mode-0644 file"
  done
}

# A refused run must leave the packaged theme as it was and must not have
# created or activated a custom one.
assert_nothing_published() {
  local context=$1

  [[ $(cat "$theme/bullet.png") == 'old plymouth bullet.png' ]] || fail "$context"
  [[ ! -e $custom_theme && ! -e $custom_sddm && ! -e $custom_conf ]] || fail "$context (no custom theme is created)"
  if [[ -e $sudo_log ]] && grep -Fq 'command plymouth-set-default-theme' "$sudo_log"; then
    fail "$context (no Plymouth theme is activated)"
  fi
}

# A machine that already chose a theme has custom directories, which may hold
# symlinks planted through earlier paths. Publication must replace them.
plant_custom_theme() {
  mkdir -p "$custom_theme" "$custom_sddm"
  chmod 0755 "$custom_theme" "$custom_sddm"
  printf 'old custom bullet.png\n' >"$custom_theme/bullet.png"
  chmod 0600 "$custom_theme/bullet.png"
  ln -s "$plymouth_victim" "$custom_theme/omarchy.script"
  ln -s "$sddm_victim" "$custom_sddm/Main.qml"
  ln -s "$legacy_victim" "$custom_conf"
}

for requested_umask in 022 027 077; do
  setup_fresh_run
  output=$(run_set "$requested_umask" env 2>&1)
  status=$?
  (( status == 0 )) || fail "Plymouth publisher succeeds under umask $requested_umask" "$output"

  for asset in "${plymouth_custom_assets[@]}"; do
    destination="$custom_theme/$asset"
    [[ -f $destination && ! -L $destination ]] || fail "Plymouth $asset is a regular file under umask $requested_umask"
    [[ $(stat -c %a "$destination") == 644 ]] || fail "Plymouth $asset is mode 0644 under umask $requested_umask"
    [[ -s $destination ]] || fail "Plymouth $asset is nonempty under umask $requested_umask"
  done
  for asset in "${sddm_default_assets[@]}"; do
    destination="$custom_sddm/$asset"
    [[ -f $destination && ! -L $destination ]] || fail "SDDM $asset is a regular file under umask $requested_umask"
    [[ $(stat -c %a "$destination") == 644 ]] || fail "SDDM $asset is mode 0644 under umask $requested_umask"
    [[ -s $destination ]] || fail "SDDM $asset is nonempty under umask $requested_umask"
  done

  cmp -s "$test_tmp/logo.png" "$custom_theme/logo.png" || fail "Plymouth receives the selected logo under umask $requested_umask"
  cmp -s "$test_tmp/logo.png" "$custom_sddm/logo.png" || fail "SDDM receives the selected logo under umask $requested_umask"
  grep -Fq '#1d2021' "$custom_sddm/Main.qml" || fail "SDDM Main.qml receives the selected background under umask $requested_umask"
  grep -Fq 'Window.SetBackgroundTopColor(0.114, 0.125, 0.129);' "$custom_theme/omarchy.script" || fail "Plymouth script receives the selected background under umask $requested_umask"
  grep -Fxq "ImageDir=$custom_theme" "$custom_theme/omarchy-custom.plymouth" || fail "the custom Plymouth theme loads its own images"
  grep -Fxq "ScriptFile=$custom_theme/omarchy.script" "$custom_theme/omarchy-custom.plymouth" || fail "the custom Plymouth theme runs its own script"
  [[ $(cat "$custom_conf") == $'[Theme]\nCurrent=omarchy-custom' && $(stat -c %a "$custom_conf") == 644 ]] || fail "theme set points SDDM at the custom theme"

  # The packaged theme belongs to omarchy-settings, and every upgrade of it
  # would overwrite a selection published there (#16473).
  assert_packaged_assets "theme set leaves" "$ROOT/default/plymouth" "$theme" "${plymouth_default_assets[@]}"
  assert_packaged_assets "theme set leaves" "$ROOT/default/sddm/omarchy" "$sddm" "${sddm_default_assets[@]}"
  [[ ! -s $leak_log ]] || fail "no privileged command receives a user-writable staged pathname" "$(cat "$leak_log")"
  [[ $(stat -c %a "$custom_theme") == 755 && $(stat -c %a "$custom_sddm") == 755 ]] || fail "theme set creates mode-0755 custom directories under umask $requested_umask"
  grep -Fxq 'command plymouth-set-default-theme omarchy-custom' "$sudo_log" || fail "theme set activates the custom Plymouth theme"
  grep -Fq 'command mkinitcpio -P' "$sudo_log" || fail "theme set rebuilds the initramfs"
  assert_no_temporary_files "$fake_root"
done

pass "theme set publishes a complete custom theme across restrictive umasks and leaves the packaged one alone"

# A machine that already chose a theme has custom destinations, possibly with
# restrictive modes and symlinks. Setting a theme again must replace only the
# destination entries and must never write through those symlinks.
setup_run
plant_custom_theme
output=$(run_set 022 env 2>&1)
status=$?

(( status == 0 )) || fail "theme set replaces existing custom destinations" "$output"
[[ -f $custom_theme/omarchy.script && ! -L $custom_theme/omarchy.script ]] || fail "theme set replaces a custom Plymouth destination symlink"
[[ -f $custom_sddm/Main.qml && ! -L $custom_sddm/Main.qml ]] || fail "theme set replaces a custom SDDM destination symlink"
[[ -f $custom_conf && ! -L $custom_conf ]] || fail "theme set replaces a symlinked SDDM drop-in"
[[ $(stat -c %a "$custom_theme/bullet.png") == 644 ]] || fail "theme set repairs a restrictive custom destination mode"
[[ $(cat "$plymouth_victim") == 'PLYMOUTH VICTIM' && $(stat -c %a "$plymouth_victim") == 600 ]] || fail "theme set never changes a Plymouth symlink victim"
[[ $(cat "$sddm_victim") == 'SDDM VICTIM' && $(stat -c %a "$sddm_victim") == 600 ]] || fail "theme set never changes an SDDM symlink victim"
[[ $(cat "$legacy_victim") == 'LEGACY VICTIM' && $(stat -c %a "$legacy_victim") == 600 ]] || fail "theme set never changes the drop-in symlink victim"
[[ -L $theme/omarchy.script && -L $sddm/Main.qml ]] || fail "theme set leaves the packaged destinations alone"
assert_no_temporary_files "$fake_root"

pass "theme set replaces existing custom destinations without following symlinks"

# White uses #ffffff behind #000000 text. A direct two-expression sed first
# writes the white background and then consumes it as if it were the template's
# text placeholder, producing a black-on-black greeter.
setup_run
output=$(run_set_colors 022 '#ffffff' '#000000' env 2>&1)
status=$?
(( status == 0 )) || fail "White theme publishes through the safe asset pipeline" "$output"
grep -Fq 'color: "#ffffff"' "$custom_sddm/Main.qml" || fail "White theme preserves its SDDM background color"
if grep -Fq '__OMARCHY_SDDM_' "$custom_sddm/Main.qml"; then
  fail "SDDM color substitution left an intermediate token behind"
fi
pass "White theme keeps a white SDDM background instead of becoming black-on-black"

# Swap the selected logo to an unreadable file in the DEBUG hook immediately
# before Bash opens its descriptor. The caller-side open must fail, so sudo
# never starts and nothing is published.
setup_run
preopen_hook="$run_dir/preopen-hook"
preopen_marker="$run_dir/preopen-marker"
printf 'ROOT ONLY\n' >"$secret"
chmod 000 "$secret"
cat >"$preopen_hook" <<'SH'
if [[ $0 == */bin/omarchy-plymouth-set ]]; then
  set -T
  trap '
    if [[ $BASH_COMMAND == exec* && $BASH_COMMAND == *logo_fd* &&
          ! -e $TEST_PREOPEN_MARKER ]]; then
      mv -T -- "$logo_path" "$logo_path.before-preopen-swap"
      ln -s -- "$TEST_SECRET" "$logo_path"
      printf "swapped\n" >"$TEST_PREOPEN_MARKER"
    fi
  ' DEBUG
fi
SH

output=$(TEST_PREOPEN_MARKER="$preopen_marker" TEST_SECRET="$secret" BASH_ENV="$preopen_hook" run_set 077 env 2>&1)
status=$?
chmod 0600 "$secret"
rm -f "$test_tmp/logo.png"
mv "$test_tmp/logo.png.before-preopen-swap" "$test_tmp/logo.png"

(( status != 0 )) || fail "an unreadable pre-open source swap aborts publication"
[[ -s $preopen_marker ]] || fail "the pre-open source swap ran deterministically" "$output"
assert_nothing_published "pre-open failure leaves the live destination unchanged"
[[ $(cat "$plymouth_victim") == 'PLYMOUTH VICTIM' ]] || fail "pre-open failure leaves destination-link victims unchanged"
if [[ -e $sudo_log ]] && grep -Fq 'root transaction' "$sudo_log"; then
  fail "sudo started despite the caller-side open failure"
fi
assert_no_temporary_files "$fake_root"

pass "an unreadable source swap before open fails without publication"

# Opening a directory read-only succeeds on Linux, but the resulting descriptor
# is not a regular file. Swap one in immediately before exec: this gets past the
# open itself and makes the /proc descriptor check the only caller-side control
# that can stop sudo from starting.
setup_run
nonregular_hook="$run_dir/nonregular-hook"
nonregular_marker="$run_dir/nonregular-marker"
cat >"$nonregular_hook" <<'SH'
if [[ $0 == */bin/omarchy-plymouth-set ]]; then
  set -T
  trap '
    if [[ $BASH_COMMAND == exec* && $BASH_COMMAND == *logo_fd* &&
          ! -e $TEST_NONREGULAR_MARKER ]]; then
      mv -T -- "$logo_path" "$logo_path.before-nonregular-swap"
      mkdir -- "$logo_path"
      printf "swapped\n" >"$TEST_NONREGULAR_MARKER"
    fi
  ' DEBUG
fi
SH

output=$(TEST_NONREGULAR_MARKER="$nonregular_marker" BASH_ENV="$nonregular_hook" run_set 077 env 2>&1)
status=$?
rmdir "$test_tmp/logo.png"
mv "$test_tmp/logo.png.before-nonregular-swap" "$test_tmp/logo.png"

(( status != 0 )) || fail "a non-regular opened logo descriptor aborts publication"
[[ -s $nonregular_marker ]] || fail "the non-regular pre-open source swap ran deterministically" "$output"
[[ $output == *"no longer a regular file"* ]] || fail "the descriptor check says why it refused the opened directory" "$output"
if [[ -e $sudo_log ]] && grep -Fq 'root transaction' "$sudo_log"; then
  fail "sudo started despite the non-regular opened logo descriptor"
fi
assert_nothing_published "a non-regular opened logo leaves the live logo unchanged"
assert_no_temporary_files "$fake_root"

pass "the caller refuses an opened descriptor that is not a regular file"

# Plant both a malicious script and a root-file symlink where the old
# caller-owned stage lived. The privileged transaction must ignore that tree:
# executable/config assets come only from its root-trusted source and are built
# in its own root-owned stage.
setup_run
attacker_stage="$stages/tmp.attacker"
mkdir -p "$attacker_stage/plymouth"
printf 'MALICIOUS BOOT SCRIPT\n' >"$attacker_stage/plymouth/omarchy.script"
ln -s "$secret" "$attacker_stage/plymouth/logo.png"

output=$(run_set 022 env 2>&1)
status=$?

(( status == 0 )) || fail "a planted caller-owned stage cannot disrupt publication" "$output"
! grep -Rqs 'MALICIOUS BOOT SCRIPT' "$fake_root" || fail "caller-owned staged content reached the boot theme"
[[ -f $custom_theme/omarchy.script && ! -L $custom_theme/omarchy.script ]] || fail "the trusted Plymouth script is published as a regular file"
grep -Fq 'Window.SetBackgroundTopColor(0.114, 0.125, 0.129);' "$custom_theme/omarchy.script" || fail "the installed script was derived from the trusted packaged source"
unexpected_stages=$(find "$stages" -mindepth 1 -maxdepth 1 ! -name tmp.attacker -print)
[[ -z $unexpected_stages ]] || fail "the caller created an authoritative staging directory" "$unexpected_stages"
assert_no_temporary_files "$fake_root"

pass "caller-owned content cannot enter the root-owned boot-image stage"

# A user-owned source checkout would put the same pre-hash race on the input
# side of the root stage. Refuse it before any fixed destination is replaced.
setup_run
output=$(run_set 022 env TEST_UNTRUSTED_SOURCE="$ROOT/default/plymouth" 2>&1)
status=$?

(( status != 0 )) || fail "a user-owned packaged source tree is rejected"
assert_nothing_published "an untrusted packaged source leaves the live theme unchanged"
[[ -L $theme/omarchy.script && $(cat "$plymouth_victim") == 'PLYMOUTH VICTIM' ]] || fail "an untrusted source cannot replace executable Plymouth content"
[[ $output == *"refusing to publish"* ]] || fail "a rejected packaged source says why it refused" "$output"
assert_no_temporary_files "$fake_root"

pass "root rejects packaged assets that a desktop process could rewrite"

# A packaged filename may not redirect root to some other readable file. Use
# the explicitly authorized development-source path so its ordinary file-mode
# checks are intentionally skipped and only the leaf symlink/canonical-file
# checks can decide this case.
setup_run
symlink_source_root=$(mktemp -d "$test_tmp/symlink-source.XXXXXXXX")
symlink_source_root=$(realpath -e -- "$symlink_source_root")
mkdir -p "$symlink_source_root/default"
cp -a "$ROOT/default/plymouth" "$ROOT/default/sddm" "$symlink_source_root/default/"
rm -f "$symlink_source_root/default/plymouth/bullet.png"
ln -s "$secret" "$symlink_source_root/default/plymouth/bullet.png"
printf 'export OMARCHY_PATH="%s"\n' "$symlink_source_root" >"$omarchy_conf"
chmod 0644 "$omarchy_conf"
output=$(run_set 022 env OMARCHY_PATH="$symlink_source_root" TEST_UNTRUSTED_SOURCE="$symlink_source_root" 2>&1)
status=$?

(( status != 0 )) || fail "a symlinked packaged asset is rejected" "$output"
assert_nothing_published "a packaged source symlink leaves the live theme unchanged"
[[ $output == *"refusing to publish"* ]] || fail "a rejected packaged source symlink says why it refused" "$output"
assert_no_temporary_files "$fake_root"

pass "root never follows a packaged asset symlink"

# A random user-owned OMARCHY_PATH remains untrusted. Only the exact canonical
# checkout recorded by root in /etc/omarchy.conf is the supported dev-link
# exception; an unrelated or stale authorization must not weaken the check.
setup_run
output=$(run_set 022 env TEST_UNTRUSTED_SOURCE="$ROOT" 2>&1)
status=$?

(( status != 0 )) || fail "a user-owned OMARCHY_PATH is rejected"
[[ $output == *"user-owned"* ]] || fail "the refusal names the untrusted source tree" "$output"
[[ $output == *"omarchy dev link"* ]] || fail "the refusal names how to authorize a development checkout" "$output"
assert_nothing_published "a user-owned OMARCHY_PATH leaves the live theme unchanged"
assert_no_temporary_files "$fake_root"

setup_run
printf 'export OMARCHY_PATH="/some/other/checkout"\n' >"$omarchy_conf"
chmod 0644 "$omarchy_conf"
output=$(run_set 022 env TEST_UNTRUSTED_SOURCE="$ROOT" 2>&1)
status=$?

(( status != 0 )) || fail "a stale dev-link authorization is rejected"
assert_nothing_published "a stale dev-link authorization leaves the live theme unchanged"
# The refusal has to name the authorization. Validating /etc/omarchy.conf walks
# its parents and leaves that walk's subject in failure_context, so without
# restoring ours this refuses with "directory / must be root-owned and not
# group- or world-writable" -- accusing a directory that passed and pointing the
# reader at a filesystem problem that does not exist.
[[ $output == *"$omarchy_conf"* ]] || fail "a stale dev-link refusal names the authorization it rejected" "$output"
[[ $output != *"directory / "* ]] || fail "a stale dev-link refusal does not blame the root directory" "$output"
assert_no_temporary_files "$fake_root"

setup_run
printf 'export OMARCHY_PATH="%s"\n' "$ROOT" >"$omarchy_conf"
chmod 0666 "$omarchy_conf"
output=$(run_set 022 env TEST_UNTRUSTED_SOURCE="$ROOT" 2>&1)
status=$?

(( status != 0 )) || fail "a writable dev-link authorization is rejected"
assert_nothing_published "a writable dev-link authorization leaves the live theme unchanged"
assert_no_temporary_files "$fake_root"

setup_run
authorization_target="$run_dir/authorization-target"
printf 'export OMARCHY_PATH="%s"\n' "$ROOT" >"$authorization_target"
chmod 0644 "$authorization_target"
ln -s "$authorization_target" "$omarchy_conf"
output=$(run_set 022 env TEST_UNTRUSTED_SOURCE="$ROOT" 2>&1)
status=$?

(( status != 0 )) || fail "a symlinked dev-link authorization is rejected"
assert_nothing_published "a symlinked dev-link authorization leaves the live theme unchanged"
assert_no_temporary_files "$fake_root"

setup_run
printf 'export OMARCHY_PATH="%s"\n' "$ROOT" >"$omarchy_conf"
chmod 0644 "$omarchy_conf"
output=$(run_set 022 env TEST_UNTRUSTED_SOURCE="$ROOT" TEST_UNTRUSTED_CONFIGURATION="$omarchy_conf" 2>&1)
status=$?

(( status != 0 )) || fail "a user-owned dev-link authorization is rejected"
assert_nothing_published "a user-owned dev-link authorization leaves the live theme unchanged"
assert_no_temporary_files "$fake_root"

setup_run
printf 'export OMARCHY_PATH="%s"\n' "$ROOT" >"$omarchy_conf"
chmod 0644 "$omarchy_conf"
output=$(run_set 022 env TEST_UNTRUSTED_SOURCE="$ROOT" 2>&1)
status=$?

(( status == 0 )) || fail "the root-authorized development checkout can publish Plymouth assets" "$output"
cmp -s "$ROOT/default/plymouth/bullet.png" "$custom_theme/bullet.png" || fail "the authorized development checkout supplies the packaged assets"

pass "only a regular root-owned authorization may name the exact development checkout"

# Root rejects both a symlinked and a group/world-writable custom directory
# before it creates a temporary file or touches what is already there.
setup_run
mkdir -m 0755 "$custom_theme.real"
printf 'old custom bullet.png\n' >"$custom_theme.real/bullet.png"
ln -s "$custom_theme.real" "$custom_theme"
output=$(run_set 022 env 2>&1)
status=$?
(( status != 0 )) || fail "a symlinked custom destination is rejected"
[[ $(cat "$custom_theme.real/bullet.png") == 'old custom bullet.png' ]] || fail "a symlinked custom destination leaves its target unchanged"
[[ $output == *"refusing to publish"* ]] || fail "a rejected symlinked destination says why it refused" "$output"
! grep -Fq 'command plymouth-set-default-theme' "$sudo_log" || fail "a rejected symlinked destination activates nothing"
assert_no_temporary_files "$fake_root"

setup_run
plant_custom_theme
chmod 0777 "$custom_theme"
output=$(run_set 022 env 2>&1)
status=$?
(( status != 0 )) || fail "a writable custom destination is rejected"
[[ $(cat "$custom_theme/bullet.png") == 'old custom bullet.png' ]] || fail "a writable custom destination keeps its live file"
[[ $output == *"refusing to publish"* ]] || fail "a rejected writable destination says why it refused" "$output"
assert_no_temporary_files "$fake_root"

pass "publication rejects symlinked and non-root-writable custom destinations"

# Walking the whole chain, not just the immediate parent, is what closes the
# rename race: a writable ancestor lets an attacker swap an entire validated
# directory out from under the leaf. Root must refuse before it creates the
# custom directory there.
setup_run
chmod 0777 "$fake_root/usr/share/plymouth"
output=$(run_set 022 env 2>&1)
status=$?
chmod 0755 "$fake_root/usr/share/plymouth"

(( status != 0 )) || fail "a writable destination ancestor is rejected" "$output"
assert_nothing_published "a writable ancestor leaves the live destination unchanged"
[[ $output == *"refusing to publish"* ]] || fail "a rejected ancestor says why it refused" "$output"
assert_no_temporary_files "$fake_root"

pass "publication walks the whole parent chain, not only the immediate parent"

# Mode is not the only thing that decides a destination directory. One that is
# merely user-owned still lets its owner put the file back after we publish, so
# ownership has to refuse it even when 0755 looks harmless.
setup_run
plant_custom_theme
output=$(run_set 022 env TEST_UNTRUSTED_SOURCE="$custom_theme" 2>&1)
status=$?

(( status != 0 )) || fail "a user-owned destination directory is rejected" "$output"
[[ $(cat "$custom_theme/bullet.png") == 'old custom bullet.png' ]] || fail "a user-owned destination directory keeps its live file"
[[ $output == *"refusing to publish"* ]] || fail "a rejected destination directory says why it refused" "$output"
assert_no_temporary_files "$fake_root"

pass "publication refuses a destination directory root does not own"

# The packaged tree is validated file by file, not only directory by directory.
# A single user-owned asset inside an otherwise root-owned directory is still
# content a desktop process can rewrite, and the directory check cannot see it.
setup_run
output=$(run_set 022 env TEST_UNTRUSTED_SOURCE="$ROOT/default/plymouth/bullet.png" 2>&1)
status=$?

(( status != 0 )) || fail "a single user-owned packaged asset is rejected" "$output"
assert_nothing_published "one untrusted asset leaves the live theme unchanged"
[[ $output == *"refusing to publish"* ]] || fail "a rejected packaged asset says why it refused" "$output"
assert_no_temporary_files "$fake_root"

pass "root checks every packaged asset, not only its directory"

# Keep every file root-owned and mode 0644 while making only its containing
# directory writable. Per-file checks cannot close the rename race in that
# state; the packaged source parent-chain walk must reject it.
setup_run
writable_directory_root=$(mktemp -d "$test_tmp/writable-directory-source.XXXXXXXX")
writable_directory_root=$(realpath -e -- "$writable_directory_root")
mkdir -p "$writable_directory_root/default"
cp -a "$ROOT/default/plymouth" "$ROOT/default/sddm" "$writable_directory_root/default/"
chmod 0777 "$writable_directory_root/default/plymouth"
output=$(run_set 022 env OMARCHY_PATH="$writable_directory_root" 2>&1)
status=$?

(( status != 0 )) || fail "a writable packaged source directory is rejected" "$output"
assert_nothing_published "a writable packaged directory leaves the live theme unchanged"
[[ $output == *"refusing to publish"* ]] || fail "a rejected packaged directory says why it refused" "$output"
assert_no_temporary_files "$fake_root"

pass "root validates the packaged source parent chain before copying"

# Ownership is not the only way a packaged asset stays rewritable: a group- or
# world-writable mode does it too. Stage a tree the shim reports as root-owned
# so only the real mode can decide, then loosen one asset.
setup_run
writable_root=$(mktemp -d "$test_tmp/writable-source.XXXXXXXX")
writable_root=$(realpath -e -- "$writable_root")
mkdir -p "$writable_root/default"
cp -a "$ROOT/default/plymouth" "$ROOT/default/sddm" "$writable_root/default/"
chmod 0666 "$writable_root/default/plymouth/bullet.png"
output=$(run_set 022 env OMARCHY_PATH="$writable_root" 2>&1)
status=$?

(( status != 0 )) || fail "a world-writable packaged asset is rejected" "$output"
assert_nothing_published "a writable packaged asset leaves the live theme unchanged"
[[ $output == *"refusing to publish"* ]] || fail "a rejected writable asset says why it refused" "$output"
assert_no_temporary_files "$fake_root"

pass "root refuses a packaged asset its own mode leaves rewritable"

# The caller streams the logo to root over a descriptor, so root is the only
# place its length can be judged. An empty selection must not become an empty
# published logo.
setup_run
cp -- "$test_tmp/logo.png" "$test_tmp/logo.png.keep"
: >"$test_tmp/logo.png"
output=$(run_set 022 env 2>&1)
status=$?
mv -f -- "$test_tmp/logo.png.keep" "$test_tmp/logo.png"

(( status != 0 )) || fail "an empty logo is rejected" "$output"
assert_nothing_published "an empty logo leaves the live logo unchanged"
assert_no_temporary_files "$fake_root"

pass "an empty logo cannot be published"

# Bound the descriptor read as well as the final destination. A sparse file
# makes the real 64 MiB + 1 byte boundary deterministic without storing a
# large fixture in the repository.
setup_run
cp -- "$test_tmp/logo.png" "$test_tmp/logo.png.keep"
truncate -s "$((64 * 1024 * 1024 + 1))" "$test_tmp/logo.png"
output=$(run_set 022 env 2>&1)
status=$?
mv -f -- "$test_tmp/logo.png.keep" "$test_tmp/logo.png"

(( status != 0 )) || fail "an oversized logo is rejected" "$output"
assert_nothing_published "an oversized logo leaves the live logo unchanged"
assert_no_temporary_files "$fake_root"

pass "a logo larger than the publication bound cannot be published"

# Refresh uses the same publisher but its explicit contract includes the
# packaged nested logos/oma.png asset. It must not touch the SDDM theme.
setup_run
output=$(run_refresh_plymouth 2>&1)
status=$?
(( status == 0 )) || fail "Plymouth refresh succeeds through the safe publisher" "$output"

assert_packaged_assets "Plymouth refresh" "$ROOT/default/plymouth" "$theme" "${plymouth_default_assets[@]}"
[[ -L $sddm/Main.qml && $(cat "$sddm_victim") == 'SDDM VICTIM' ]] || fail "Plymouth refresh leaves SDDM unchanged"
! grep -Fq 'transaction /usr/share/sddm/' "$sudo_log" || fail "Plymouth refresh does not publish SDDM assets"
[[ ! -s $leak_log ]] || fail "refresh never gives root a user-writable source pathname" "$(cat "$leak_log")"
grep -Fxq 'command plymouth-set-default-theme omarchy' "$sudo_log" || fail "Plymouth refresh activates the restored theme"
grep -Fq 'command mkinitcpio -P' "$sudo_log" || fail "Plymouth refresh rebuilds the initramfs"

pass "refresh safely publishes its complete fixed asset set, including logos/oma.png"

# SDDM refresh has the same fixed-file contract but must leave Plymouth and the
# boot image alone. It also replaces legacy destination symlinks without
# changing their victims.
setup_run
plant_custom_theme
output=$(run_refresh_sddm 2>&1)
status=$?
(( status == 0 )) || fail "SDDM refresh succeeds through the safe publisher" "$output"
[[ ! -e $custom_conf && ! -L $custom_conf ]] || fail "SDDM refresh removes the custom theme drop-in"

assert_packaged_assets "SDDM refresh" "$ROOT/default/sddm/omarchy" "$sddm" "${sddm_default_assets[@]}"
[[ -L $theme/omarchy.script && $(cat "$plymouth_victim") == 'PLYMOUTH VICTIM' ]] || fail "SDDM refresh leaves Plymouth unchanged"
[[ $(cat "$sddm_victim") == 'SDDM VICTIM' && $(stat -c %a "$sddm_victim") == 600 ]] || fail "SDDM refresh never changes a destination symlink victim"
[[ $(cat "$legacy_victim") == 'LEGACY VICTIM' && $(stat -c %a "$legacy_victim") == 600 ]] || fail "SDDM refresh never changes the legacy logo victim"
[[ ! -e $sddm/logo.svg && ! -L $sddm/logo.svg ]] || fail "SDDM refresh removes the legacy logo.svg"
! grep -Fq 'command plymouth-set-default-theme' "$sudo_log" || fail "SDDM refresh does not activate Plymouth"
! grep -Fq 'command mkinitcpio' "$sudo_log" || fail "SDDM refresh does not rebuild the initramfs"
[[ ! -s $leak_log ]] || fail "SDDM refresh never gives root a user-writable source pathname" "$(cat "$leak_log")"

pass "SDDM refresh safely restores its complete packaged asset set without rebuilding Plymouth"

# A fresh package installation already contains the complete default file set.
# Reset must be safe and idempotent in that ordinary state.
setup_fresh_run
output=$(run_reset 2>&1)
status=$?
(( status == 0 )) || fail "reset succeeds on a fresh installation" "$output"

assert_packaged_assets "fresh reset Plymouth" "$ROOT/default/plymouth" "$theme" "${plymouth_default_assets[@]}"
assert_packaged_assets "fresh reset SDDM" "$ROOT/default/sddm/omarchy" "$sddm" "${sddm_default_assets[@]}"
grep -Fxq 'command plymouth-set-default-theme omarchy' "$sudo_log" || fail "fresh reset activates the packaged Plymouth theme"
grep -Fq 'command mkinitcpio -P' "$sudo_log" || fail "fresh reset rebuilds the initramfs"
assert_no_temporary_files "$fake_root"

pass "reset is safe and idempotent on a fresh package installation"

# Picking default after a theme goes back to the packaged theme, and the
# custom selection stops being active for both Plymouth and SDDM.
setup_fresh_run
output=$(run_set 022 env 2>&1)
status=$?
(( status == 0 )) || fail "theme set succeeds before a reset" "$output"
output=$(run_reset 2>&1)
status=$?
(( status == 0 )) || fail "reset after a theme set succeeds" "$output"
[[ $(grep '^command plymouth-set-default-theme' "$sudo_log" | tail -n 1) == 'command plymouth-set-default-theme omarchy' ]] ||
  fail "reset activates the packaged Plymouth theme last" "$(cat "$sudo_log")"
[[ ! -e $custom_conf ]] || fail "reset stops pointing SDDM at the custom theme"

pass "reset after a theme set returns Plymouth and SDDM to the packaged theme"

# Exercise an existing hostile state: destination symlinks stand in for an
# upgraded machine that may already contain artifacts planted through the old
# paths. Each refresh must replace its own entries without following them.
setup_run
output=$(run_reset 2>&1)
status=$?
(( status == 0 )) || fail "combined Plymouth and SDDM reset succeeds" "$output"

assert_packaged_assets "migrated reset Plymouth" "$ROOT/default/plymouth" "$theme" "${plymouth_default_assets[@]}"
assert_packaged_assets "migrated reset SDDM" "$ROOT/default/sddm/omarchy" "$sddm" "${sddm_default_assets[@]}"
[[ $(cat "$plymouth_victim") == 'PLYMOUTH VICTIM' && $(stat -c %a "$plymouth_victim") == 600 ]] || fail "reset never changes a Plymouth destination symlink victim"
[[ $(cat "$sddm_victim") == 'SDDM VICTIM' && $(stat -c %a "$sddm_victim") == 600 ]] || fail "reset never changes an SDDM destination symlink victim"
[[ $(cat "$legacy_victim") == 'LEGACY VICTIM' && $(stat -c %a "$legacy_victim") == 600 ]] || fail "reset never changes the legacy logo victim"
[[ ! -e $sddm/logo.svg && ! -L $sddm/logo.svg ]] || fail "reset removes the legacy logo.svg"
grep -Fxq 'command plymouth-set-default-theme omarchy' "$sudo_log" || fail "reset activates the restored Plymouth theme"
grep -Fq 'command mkinitcpio -P' "$sudo_log" || fail "reset rebuilds the initramfs"
[[ ! -s $leak_log ]] || fail "reset never gives root a user-writable source pathname" "$(cat "$leak_log")"

pass "reset safely repairs a migrated Plymouth and SDDM installation"

# A damaged installation may retain its package-owned directories while some
# destination files are missing. Reset must recreate every allowlisted leaf.
setup_run
for asset in "${plymouth_default_assets[@]}"; do
  rm -f -- "$theme/$asset"
done
for asset in "${sddm_default_assets[@]}"; do
  rm -f -- "$sddm/$asset"
done
rm -f -- "$sddm/logo.svg"
output=$(run_reset 2>&1)
status=$?
(( status == 0 )) || fail "reset repairs missing Plymouth and SDDM destinations" "$output"
assert_packaged_assets "missing-file reset Plymouth" "$ROOT/default/plymouth" "$theme" "${plymouth_default_assets[@]}"
assert_packaged_assets "missing-file reset SDDM" "$ROOT/default/sddm/omarchy" "$sddm" "${sddm_default_assets[@]}"

pass "reset recreates missing files in package-owned destination trees"

# The two refreshes are independently hardened. If Plymouth succeeds and SDDM
# then refuses its unsafe destination, the completed Plymouth refresh remains
# valid while SDDM and its symlink victims remain unchanged.
setup_run
chmod 0777 "$sddm"
output=$(run_reset 2>&1)
status=$?

(( status != 0 )) || fail "reset rejects an unsafe SDDM destination" "$output"
assert_packaged_assets "Plymouth before SDDM refusal" "$ROOT/default/plymouth" "$theme" "${plymouth_default_assets[@]}"
[[ $(cat "$plymouth_victim") == 'PLYMOUTH VICTIM' ]] || fail "the successful Plymouth refresh never changes its old symlink victim"
[[ -L $sddm/Main.qml && $(cat "$sddm_victim") == 'SDDM VICTIM' ]] || fail "a rejected reset leaves SDDM unchanged"
[[ $output == *"refusing to publish"* ]] || fail "an unsafe reset destination says why it refused" "$output"
assert_no_temporary_files "$fake_root"

pass "an SDDM refusal cannot make either refresh follow an unsafe destination"

# A packaged source that fails the root trust checks must stop the combined
# reset; it cannot fall through into a second legacy SDDM copy.
setup_run
output=$(run_reset env TEST_UNTRUSTED_SOURCE="$ROOT" 2>&1)
status=$?

(( status != 0 )) || fail "reset rejects an untrusted packaged source" "$output"
assert_nothing_published "an untrusted reset source leaves Plymouth unchanged"
[[ -L $sddm/Main.qml && $(cat "$sddm_victim") == 'SDDM VICTIM' ]] || fail "an untrusted reset source leaves SDDM unchanged"
[[ $output == *"refusing to publish"* ]] || fail "an untrusted reset source says why it refused" "$output"
[[ $(grep -c '^root transaction$' "$sudo_log") == 1 ]] || fail "reset stops before SDDM when Plymouth refuses"
assert_no_temporary_files "$fake_root"

pass "a reset refusal cannot fall through to an unhardened SDDM copy"
