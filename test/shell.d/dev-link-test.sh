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
    # The staged file is the second-to-last argument.
    cp "${@: -2:1}" "$OMARCHY_DEV_LINK_TEST_SUDOERS"
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

cat >"$stub_bin/realpath" <<'SH'
#!/bin/bash
while (( $# )); do
  case "$1" in
    -e|--canonicalize-existing) shift ;;
    -*) shift ;;
    *) break ;;
  esac
done
[[ -n ${1:-} && -e $1 ]] || exit 1
printf '%s\n' "$1"
SH
chmod +x "$stub_bin/realpath"

runtime_dir="$test_tmp/runtime"
mkdir -m 700 -p "$runtime_dir"

run_link() {
  HOME="$test_tmp/home" \
    XDG_RUNTIME_DIR="$runtime_dir" \
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

staged_path=$(awk -F '\t' '$1 == "sudo" && $2 == "install" { print $(NF-1) }' "$log_file")
[[ $staged_path == "$runtime_dir"/omarchy-dev-path.* ]] ||
  fail "dev link stages sudoers under XDG_RUNTIME_DIR" "$(cat "$log_file")"
pass "dev link stages sudoers under XDG_RUNTIME_DIR"

if grep -Fq 'staged_sudoers=$(mktemp)' "$ROOT/bin/omarchy-dev-link"; then
  fail "dev link must not mktemp sudoers in the default /tmp"
fi
grep -Fq '${XDG_RUNTIME_DIR:-/tmp/omarchy-$UID}' "$ROOT/bin/omarchy-dev-link" ||
  fail "dev link falls back to a 0700 /tmp/omarchy-\$UID directory"
pass "dev link does not stage sudoers in world-writable /tmp"

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
