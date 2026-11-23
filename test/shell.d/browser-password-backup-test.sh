#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"

# pgrep stub: logs the process name it was asked about, reports "running" only
# when the test says so. The real pgrep exits 0 when it found processes.
cat >"$stub_bin/pgrep" <<SH
#!/bin/bash
printf 'pgrep %s\n' "\$*" >>"\$OMARCHY_TEST_PGREP_LOG"
[[ -n \$OMARCHY_TEST_BROWSER_RUNNING ]]
SH
chmod +x "$stub_bin/pgrep"

pgrep_log="$test_tmp/pgrep-log"

run_backup() {
  local status=0
  : >"$pgrep_log"
  local stdout_file="$test_tmp/run-stdout" stderr_file="$test_tmp/run-stderr"
  env -i \
    HOME="$home" \
    PATH="$stub_bin:$ROOT/bin:/usr/bin" \
    OMARCHY_TEST_PGREP_LOG="$pgrep_log" \
    OMARCHY_TEST_BROWSER_RUNNING="${OMARCHY_TEST_BROWSER_RUNNING:-}" \
    bash "$ROOT/bin/omarchy-browser-password-backup" "$@" >"$stdout_file" 2>"$stderr_file" || status=$?
  STATUS=$status
  STDOUT=$(cat "$stdout_file")
  STDERR=$(cat "$stderr_file")
  output=$(cat "$stdout_file" "$stderr_file")
}

new_profile_fixture() {
  local profile="$1"
  mkdir -p "$profile"
  printf 'saved logins' >"$profile/Login Data"
  printf 'wal' >"$profile/Login Data-wal"
  printf 'journal' >"$profile/Login Data-journal"
  printf 'saved cookies' >"$profile/Cookies"
}

# 1. Per-profile success: brave, Default + Profile 1, one-line unpinned conf.
home=$test_tmp/case1
data="$home/.config/BraveSoftware/Brave-Browser"
conf="$home/.config/brave-flags.conf"
mkdir -p "$data/Default" "$data/Profile 1" "$home/.config"
printf '%s\n' '--enable-features=WaylandWindowDecorations' >"$conf"
new_profile_fixture "$data/Default"
new_profile_fixture "$data/Profile 1"

run_backup brave "$conf"
(( STATUS == 0 )) || fail "per-profile backup succeeds with exit 0" "$output"

backup_root="$home/.local/state/omarchy/migration-backups"
backups=("$backup_root"/*)
if (( ${#backups[@]} != 1 )) || [[ ! -d ${backups[0]} ]]; then
  fail "exactly one backup directory created" "found: ${backups[*]:-none}"
fi
backup=${backups[0]}

for profile in "Default" "Profile 1"; do
  for file in "Login Data" "Login Data-wal" "Login Data-journal" "Cookies"; do
    [[ -f "$backup/$profile/$file" ]] || fail "backup preserves $profile/$file" "missing from $backup"
  done
done
[[ $(cat "$backup/Default/Login Data") == "saved logins" ]] || fail "backup preserves file contents"

first_stdout_line=$(head -n1 <<<"$STDOUT")
[[ $first_stdout_line == "$backup" ]] || fail "stdout line 1 is the backup path" "got: $first_stdout_line, expected: $backup"

grep -q "undecryptable" <<<"$output" || fail "output warns about undecryptable databases" "$output"
grep -q -- '--password-store=gnome-libsecret' <<<"$output" || fail "output tells user to remove the pin" "$output"
grep -qF "$conf" <<<"$output" || fail "output names the flags conf path" "$output"
pass "per-profile success backs up all profiles and emits recovery message"

# 2. No profile data: chromium conf, no ~/.config/chromium.
home=$test_tmp/case2
conf="$home/.config/chromium-flags.conf"
mkdir -p "$home/.config"
printf '%s\n' '--ozone-platform-hint=auto' >"$conf"

run_backup chromium "$conf"
(( STATUS == 0 )) || fail "no-data run exits 0" "$output"
[[ ! -e "$home/.local/state/omarchy/migration-backups" ]] || fail "no backup dir created when no profiles exist"
[[ -z $STDOUT ]] || fail "no backup path printed on stdout when no profiles exist" "got: $STDOUT"
pass "browser with no profile data exits 0 without backup"

# 3. Unknown browser: omarchy-browser-password-backup firefox "$conf"
home=$test_tmp/case3
conf="$home/.config/firefox-flags.conf"
mkdir -p "$home/.config"
touch "$conf"

run_backup firefox "$conf"
(( STATUS != 0 )) || fail "unknown browser exits non-zero" "$output"
grep -q "Usage: omarchy-browser-password-backup" <<<"$STDERR" || fail "usage text printed on stderr for unknown browser" "$STDERR"
pass "unknown browser exits non-zero with usage text on stderr"

# 4. Custom --user-data-dir: three sub-cases

# 4a. conf line --user-data-dir=~/Browser Data (tilde, space), profiles under $home/Browser Data, no default data.
home=$test_tmp/case4a
conf="$home/.config/brave-flags.conf"
data="$home/Browser Data"
mkdir -p "$home/.config" "$data/Default"
printf '%s\n' '--user-data-dir=~/Browser Data' >"$conf"
new_profile_fixture "$data/Default"

run_backup brave "$conf"
(( STATUS == 0 )) || fail "custom user-data-dir (tilde, space) exits 0" "$output"
backups=("$home/.local/state/omarchy/migration-backups"/*)
(( ${#backups[@]} == 1 )) || fail "one backup created for custom user-data-dir" "found: ${backups[*]:-none}"
backup=${backups[0]}
[[ -f "$backup/Default/Login Data" ]] || fail "backup holds profile from custom user-data-dir"
[[ $(cat "$backup/Default/Login Data") == "saved logins" ]] || fail "custom dir backup preserves content"
grep -qF "$backup" <<<"$STDOUT" || fail "custom dir backup path printed on stdout" "got: $STDOUT"
pass "custom --user-data-dir with tilde and space succeeds"

# 4b. conf line --user-data-dir="$HOME/My Data" (double quotes + $HOME + space), profiles under that dir.
home=$test_tmp/case4b
conf="$home/.config/brave-flags.conf"
data="$home/My Data"
mkdir -p "$home/.config" "$data/Default"
printf '%s\n' '--user-data-dir="$HOME/My Data"' >"$conf"
new_profile_fixture "$data/Default"

run_backup brave "$conf"
(( STATUS == 0 )) || fail "custom user-data-dir (quotes + \$HOME + space) exits 0" "$output"
backups=("$home/.local/state/omarchy/migration-backups"/*)
(( ${#backups[@]} == 1 )) || fail "one backup created for custom user-data-dir" "found: ${backups[*]:-none}"
backup=${backups[0]}
[[ -f "$backup/Default/Login Data" ]] || fail "backup holds profile from quoted \$HOME user-data-dir"
grep -qF "$backup" <<<"$STDOUT" || fail "quoted \$HOME user-data-dir backup path printed on stdout" "got: $STDOUT"
pass "custom --user-data-dir with double quotes and \$HOME succeeds"

# 4c. default dir has data AND one override has data: two backup dirs, two paths printed, profiles from both present.
home=$test_tmp/case4c
conf="$home/.config/brave-flags.conf"
default_data="$home/.config/BraveSoftware/Brave-Browser"
override_data="$home/Override Data"
mkdir -p "$home/.config" "$default_data/Default" "$override_data/Profile 1"
printf '%s\n' '--user-data-dir=~/Override Data' >"$conf"
new_profile_fixture "$default_data/Default"
new_profile_fixture "$override_data/Profile 1"

run_backup brave "$conf"
(( STATUS == 0 )) || fail "default dir and override dir backup exits 0" "$output"
backups=("$home/.local/state/omarchy/migration-backups"/*)
(( ${#backups[@]} == 2 )) || fail "two backup directories created" "found: ${backups[*]:-none}"

stdout_lines=()
while IFS= read -r line; do
  [[ -n $line ]] && stdout_lines+=("$line")
done <<<"$STDOUT"
(( ${#stdout_lines[@]} == 2 )) || fail "two backup paths printed on stdout" "got: $STDOUT"

# Verify profiles from both are present across the backup directories
found_default=0
found_override=0
for b in "${backups[@]}"; do
  if [[ -f "$b/Default/Login Data" ]]; then
    found_default=1
  fi
  if [[ -f "$b/Profile 1/Login Data" ]]; then
    found_override=1
  fi
done
(( found_default == 1 )) || fail "default profile present in backup"
(( found_override == 1 )) || fail "override profile present in backup"
pass "default dir and custom user-data-dir both backed up with separate paths printed"

# 5. Unresolvable override: empty value, relative path, or unexpanded variable defers before copying.
home=$test_tmp/case5
conf="$home/.config/brave-flags.conf"
default_data="$home/.config/BraveSoftware/Brave-Browser"
mkdir -p "$home/.config" "$default_data/Default"
new_profile_fixture "$default_data/Default"

for invalid_flag in '--user-data-dir=' '--user-data-dir=relative/path' '--user-data-dir=$XDG_DATA_HOME/dir'; do
  printf '%s\n' "$invalid_flag" >"$conf"
  run_backup brave "$conf"
  (( STATUS != 0 )) || fail "unresolvable flag '$invalid_flag' exits non-zero" "$output"
  grep -q "Cannot resolve the --user-data-dir value" <<<"$STDERR" || fail "explanation on stderr for '$invalid_flag'" "$STDERR"
  [[ ! -e "$home/.local/state/omarchy/migration-backups" ]] || fail "no backup dir created for unresolvable flag '$invalid_flag'"
done
pass "unresolvable --user-data-dir override defers before any copying"

# 6. Running browser defers: brave with profile data, pgrep stub reports running.
home=$test_tmp/case6
conf="$home/.config/brave-flags.conf"
data="$home/.config/BraveSoftware/Brave-Browser"
mkdir -p "$home/.config" "$data/Default"
printf '%s\n' '--enable-features=WaylandWindowDecorations' >"$conf"
new_profile_fixture "$data/Default"

OMARCHY_TEST_BROWSER_RUNNING=1 run_backup brave "$conf"
(( STATUS != 0 )) || fail "running browser check exits non-zero" "$output"
grep -q "brave is running" <<<"$STDERR" || fail "stderr mentions brave is running" "$STDERR"
grep -q "Quit brave" <<<"$STDERR" || fail "stderr instructs to quit brave" "$STDERR"
[[ ! -e "$home/.local/state/omarchy/migration-backups" ]] || fail "no backup created while browser is running"
grep -qFx "pgrep -x brave" "$pgrep_log" || fail "pgrep invoked with exact process name 'brave'" "$(cat "$pgrep_log")"

# Repeat for microsoft-edge-stable and assert pgrep log line is msedge.
edge_conf="$home/.config/microsoft-edge-flags.conf"
printf '%s\n' '--enable-features=WaylandWindowDecorations' >"$edge_conf"
OMARCHY_TEST_BROWSER_RUNNING=1 run_backup microsoft-edge-stable "$edge_conf"
(( STATUS != 0 )) || fail "running edge check exits non-zero" "$output"
grep -qFx "pgrep -x msedge" "$pgrep_log" || fail "pgrep invoked with exact process name 'msedge'" "$(cat "$pgrep_log")"
pass "running browser defers backup and maps microsoft-edge-stable to msedge"

# 7. Copy failure: cp stub exits 1, brave with data.
home=$test_tmp/case7
conf="$home/.config/brave-flags.conf"
data="$home/.config/BraveSoftware/Brave-Browser"
mkdir -p "$home/.config" "$data/Default"
printf '%s\n' '--enable-features=WaylandWindowDecorations' >"$conf"
new_profile_fixture "$data/Default"

printf '#!/bin/bash\nexit 1\n' >"$stub_bin/cp"
chmod +x "$stub_bin/cp"

run_backup brave "$conf"
(( STATUS != 0 )) || fail "cp failure exits non-zero" "$output"
rm -f "$stub_bin/cp"
pass "copy failure returns non-zero status"
