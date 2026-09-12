#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command script

if (( EUID == 0 )); then
  pass "root skip: stay-awake does not probe sudo"
  exit 0
fi

stay_awake="$ROOT/bin/omarchy-update-stay-awake"

grep -q 'sudo -n true' "$stay_awake" ||
  fail "update stay-awake skips sudo -v when passwordless sudo already works"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

stub_bin="$tmp_dir/bin"
mkdir -p "$stub_bin" "$tmp_dir/home" "$tmp_dir/run"

cat >"$stub_bin/sudo" <<'STUB'
#!/bin/bash
printf 'sudo %s\n' "$*" >>"${CALL_LOG:?}"
if [[ ${1:-} == -n ]]; then
  if [[ ${SUDO_N_OK:-1} == 1 ]]; then
    exit 0
  fi
  echo "sudo: a password is required" >&2
  exit 1
fi
if [[ ${1:-} == -v ]]; then
  exit 0
fi
exec "$@"
STUB

cat >"$stub_bin/systemd-inhibit" <<'STUB'
#!/bin/bash
exit 0
STUB

cat >"$stub_bin/omarchy-toggle-idle" <<'STUB'
#!/bin/bash
exit 0
STUB

chmod +x "$stub_bin"/sudo "$stub_bin"/systemd-inhibit "$stub_bin"/omarchy-toggle-idle

run_start() {
  local label=$1
  local sudo_n_ok=$2
  local calls=$tmp_dir/$label.calls
  : >"$calls"

  HOME="$tmp_dir/home" \
    XDG_RUNTIME_DIR="$tmp_dir/run" \
    PATH="$stub_bin:$ROOT/bin:$PATH" \
    CALL_LOG="$calls" \
    SUDO_N_OK="$sudo_n_ok" \
    script -q -e -c "$stay_awake start" /dev/null >/dev/null

  HOME="$tmp_dir/home" \
    XDG_RUNTIME_DIR="$tmp_dir/run" \
    PATH="$stub_bin:$ROOT/bin:$PATH" \
    "$stay_awake" stop >/dev/null 2>&1 || true

  printf '%s\n' "$calls"
}

nopasswd_calls=$(run_start nopasswd 1)
grep -qxF 'sudo -n true' "$nopasswd_calls" ||
  fail "passwordless sudo is probed with sudo -n true" "$(<"$nopasswd_calls")"
if grep -qxF 'sudo -v' "$nopasswd_calls"; then
  fail "passwordless sudo does not refresh a cached timestamp" "$(<"$nopasswd_calls")"
fi
pass "passwordless sudo does not refresh a cached timestamp"

passwd_calls=$(run_start passwd 0)
grep -qxF 'sudo -n true' "$passwd_calls" ||
  fail "cached sudo is still probed with sudo -n true" "$(<"$passwd_calls")"
grep -qxF 'sudo -v' "$passwd_calls" ||
  fail "cached sudo falls back to sudo -v" "$(<"$passwd_calls")"
pass "cached sudo falls back to sudo -v"
