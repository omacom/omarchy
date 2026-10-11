#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
log_file="$test_tmp/dev-link.log"
conf_file="$test_tmp/omarchy.conf"
sudoers_file="$test_tmp/omarchy-dev-path"
mkdir -p "$stub_bin" "$test_tmp/home"

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash

printf 'sudo' >>"$OMARCHY_DEV_LINK_TEST_LOG"
for arg in "$@"; do
  printf '\t%s' "$arg" >>"$OMARCHY_DEV_LINK_TEST_LOG"
done
printf '\n' >>"$OMARCHY_DEV_LINK_TEST_LOG"

case "$1" in
  tee)
    cat >"$OMARCHY_DEV_LINK_TEST_CONF"
    ;;
  install)
    case "${@: -1}" in
      /etc/omarchy.conf)
        install "$2" "$3" "${@: -2:1}" "$OMARCHY_DEV_LINK_TEST_CONF"
        ;;
      /etc/sudoers.d/omarchy-dev-path)
        cp "${@: -2:1}" "$OMARCHY_DEV_LINK_TEST_SUDOERS"
        ;;
    esac
    ;;
esac
SH
chmod +x "$stub_bin/sudo"

cat >"$stub_bin/gum" <<'SH'
#!/bin/bash

printf 'gum' >>"$OMARCHY_DEV_LINK_TEST_LOG"
for arg in "$@"; do
  printf '\t%s' "$arg" >>"$OMARCHY_DEV_LINK_TEST_LOG"
done
printf '\n' >>"$OMARCHY_DEV_LINK_TEST_LOG"
SH
chmod +x "$stub_bin/gum"

cat >"$stub_bin/omarchy-system-reboot" <<'SH'
#!/bin/bash

printf 'reboot\n' >>"$OMARCHY_DEV_LINK_TEST_LOG"
SH
chmod +x "$stub_bin/omarchy-system-reboot"

run_link() {
  HOME="$test_tmp/home" \
    OMARCHY_DEV_LINK_TEST_LOG="$log_file" \
    OMARCHY_DEV_LINK_TEST_CONF="$conf_file" \
    OMARCHY_DEV_LINK_TEST_SUDOERS="$sudoers_file" \
    PATH="$stub_bin:$PATH" \
    "$ROOT/bin/omarchy-dev-link" "$@"
}

make_checkout() {
  local checkout="$test_tmp/$1"

  mkdir -p "$checkout/bin" "$checkout/default" "$checkout/shell"
  printf '%s' "$checkout"
}

checkout=$(make_checkout checkout)

: >"$log_file"
: >"$sudoers_file"
run_link "$checkout" --no-reboot >"$test_tmp/link.out"

[[ $(<"$conf_file") == "export OMARCHY_PATH=\"$checkout\"" ]] ||
  fail "dev link points OMARCHY_PATH at the checkout" "$(<"$conf_file")"
pass "dev link points OMARCHY_PATH at the checkout"

# sudo reads secure_path, not the caller's PATH, so the checkout has to come
# first there too or `sudo omarchy-*` runs the packaged copy.
[[ $(<"$sudoers_file") == "Defaults secure_path=\"$checkout/bin:/usr/local/sbin:/usr/local/bin:/usr/bin\"" ]] ||
  fail "dev link prepends the checkout to sudo's secure_path" "$(<"$sudoers_file")"
pass "dev link prepends the checkout to sudo's secure_path"

grep -Eq $'^sudo\tinstall\t-Dm440\t-o\troot\t-g\troot\t[^\t]+\t/etc/sudoers\\.d/omarchy-dev-path$' "$log_file" ||
  fail "dev link installs the drop-in root-owned and read-only" "$(cat "$log_file")"
pass "dev link installs the drop-in root-owned and read-only"

visudo -cf "$sudoers_file" >/dev/null ||
  fail "dev link writes a sudoers drop-in sudo can parse" "$(<"$sudoers_file")"
pass "dev link writes a sudoers drop-in sudo can parse"

grep -F "sudo now resolves omarchy-* from $checkout/bin" "$test_tmp/link.out" >/dev/null ||
  fail "dev link reports the sudo change" "$(cat "$test_tmp/link.out")"
pass "dev link reports the sudo change"

if grep -Eq '^(gum|reboot)' "$log_file"; then
  fail "dev link --no-reboot skips the reboot prompt" "$(cat "$log_file")"
fi
pass "dev link --no-reboot skips the reboot prompt"

# A path sudoers would have to escape, not one the shell alone handles.
quoted_checkout=$(make_checkout 'check "out"')

: >"$log_file"
: >"$sudoers_file"
run_link "$quoted_checkout" --no-reboot >/dev/null

visudo -cf "$sudoers_file" >/dev/null ||
  fail "dev link escapes a checkout path for sudoers" "$(<"$sudoers_file")"
pass "dev link escapes a checkout path for sudoers"

: >"$log_file"
if run_link "$test_tmp/missing" --no-reboot >/dev/null 2>"$test_tmp/missing.err"; then
  fail "dev link rejects a path that does not exist"
fi
grep -F "Error: path does not exist: $test_tmp/missing" "$test_tmp/missing.err" >/dev/null ||
  fail "dev link explains a path that does not exist" "$(cat "$test_tmp/missing.err")"
if grep -q 'sudo' "$log_file"; then
  fail "dev link touches nothing when the path does not exist" "$(cat "$log_file")"
fi
pass "dev link rejects a path that does not exist"

# Simulate a restrictive privileged umask when the config is first created,
# then an already unreadable config left by an earlier invocation.
# A config link must be replaced without changing its referent.
for config_state in missing unreadable symlink hardlink directory-symlink; do
  rm -f "$conf_file"
  victim="$test_tmp/victim-$config_state"
  printf 'private fixture\n' >"$victim"
  chmod 600 "$victim"
  victim_dir="$test_tmp/directory-$config_state"
  mkdir -p "$victim_dir"
  chmod 700 "$victim_dir"
  case "$config_state" in
    unreadable)
      touch "$conf_file"
      chmod 600 "$conf_file"
      ;;
    symlink) ln -s "$victim" "$conf_file" ;;
    hardlink) ln "$victim" "$conf_file" ;;
    directory-symlink) ln -s "$victim_dir" "$conf_file" ;;
  esac
  (umask 077; run_link "$checkout" --no-reboot >/dev/null)
  [[ -f $conf_file && ! -L $conf_file && $(stat -c '%a' "$conf_file") == "644" ]] ||
    fail "dev link replaces the $config_state config with a readable file under umask 077"
  [[ $(<"$conf_file") == "export OMARCHY_PATH=\"$checkout\"" ]] ||
    fail "dev link preserves generated config contents under umask 077"
  [[ $(<"$victim") == "private fixture" && $(stat -c '%a' "$victim") == "600" ]] ||
    fail "dev link leaves the $config_state referent contents and mode unchanged"
  [[ $(stat -c '%a' "$victim_dir") == "700" && -z $(find "$victim_dir" -mindepth 1 -print -quit) ]] ||
    fail "dev link writes nothing inside a symlinked directory"
  pass "dev link replaces the $config_state config without changing its referent"
done

rm -f "$conf_file"
mkdir "$conf_file"
chmod 700 "$conf_file"
: >"$log_file"
if run_link "$checkout" --no-reboot >/dev/null 2>"$test_tmp/directory.err"; then
  fail "dev link refuses a directory at the config path"
fi
[[ -d $conf_file && $(stat -c '%a' "$conf_file") == "700" && -z $(find "$conf_file" -mindepth 1 -print -quit) ]] ||
  fail "dev link leaves the config directory untouched"
if grep -F '/etc/sudoers.d/omarchy-dev-path' "$log_file" >/dev/null; then
  fail "dev link changes no sudoers file after the config write fails"
fi
pass "dev link refuses a directory at the config path"

grep -Fx $'sudo\tinstall\t-Dm644\t-T\t-o\troot\t-g\troot\t/dev/stdin\t/etc/omarchy.conf' "$log_file" >/dev/null ||
  fail "dev-link installs the config root-owned with mode 0644" "$(cat "$log_file")"
pass "dev-link installs the config root-owned with mode 0644"
