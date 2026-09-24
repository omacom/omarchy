#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
export HOME="$test_tmp/home" OMARCHY_PATH="$ROOT"
export AXON_TEST="$test_tmp"
mkdir -p "$HOME" "$test_tmp/bin" "$HOME/.local/share/mise/shims"
# An allowlist PATH prevents real runtimes, shims, or installers leaking in.
for tool in grep head timeout jq cp chmod cat rm mkdir touch; do
  ln -s "$(command -v "$tool")" "$test_tmp/bin/$tool"
done
ln -s "$ROOT/bin/omarchy-cmd-present" "$test_tmp/bin/omarchy-cmd-present"
export PATH="$test_tmp/bin"
installer="$ROOT/bin/omarchy-install-axon-cli"

cat >"$test_tmp/runtime" <<'SH'
#!/bin/bash
[[ $# == 1 && $1 == "--version" ]] || exit 9
[[ ${MISE_AUTO_INSTALL:-} == 0 && ${MISE_EXEC_AUTO_INSTALL:-} == 0 && ${MISE_NOT_FOUND_AUTO_INSTALL:-} == 0 ]] || exit 8
printf '%s\n' "${0##*/}" >>"$AXON_TEST/probes"
[[ ! -f "$AXON_TEST/broken-${0##*/}" ]]
SH
cat >"$test_tmp/bin/mise" <<'SH'
#!/bin/bash
[[ ${MISE_AUTO_INSTALL:-} == 0 && ${MISE_EXEC_AUTO_INSTALL:-} == 0 && ${MISE_NOT_FOUND_AUTO_INSTALL:-} == 0 ]] || exit 8
printf '%s\0' "$@" >>"$AXON_TEST/argv"
printf '\n' >>"$AXON_TEST/argv"
if [[ $# == 3 && $1 == ls && $2 == --global && $3 == --json ]]; then
  printf '%s\n' "$AXON_SELECTIONS"
elif [[ $# == 4 && $1 == use && $2 == -g && $3 == --fuzzy ]]; then
  [[ ! -f "$AXON_TEST/install-fail" ]] || exit 1
  case "$4" in
  bun@latest) tool=bun ;;
  npm:@arcforge/axon@latest)
    [[ ${MISE_MINIMUM_RELEASE_AGE:-} == 0 ]] || exit 8
    tool=axon
    ;;
  *) exit 9 ;;
  esac
  if [[ $tool == "axon" ]] && [[ -f $AXON_TEST/shim-mode ]]; then
    cp "$AXON_TEST/runtime" "$AXON_TEST/installed-axon"
  else
    cp "$AXON_TEST/runtime" "$AXON_TEST/bin/$tool"
  fi
  chmod +x "$AXON_TEST/bin/$tool" "$AXON_TEST/installed-axon" 2>/dev/null || true
else
  exit 9
fi
SH
chmod +x "$test_tmp/bin/mise" "$test_tmp/runtime"
export AXON_SELECTIONS='{"node":[{"version":"22","source":{"path":"config.toml"}}]}'

reset_case() {
  /bin/rm -f "$test_tmp/bin/axon" "$test_tmp/bin/bun" "$test_tmp"/broken-* "$test_tmp/install-fail" "$test_tmp/installed-axon" "$test_tmp/shim-mode"
  : >"$test_tmp/argv"
  : >"$test_tmp/probes"
}
runtime() { cp "$test_tmp/runtime" "$test_tmp/bin/$1"; }
reject() {
  if "$installer" "$@" >"$test_tmp/output" 2>&1; then
    fail "expected rejection: $*"
  fi
}
no_mise() { [[ ! -s $test_tmp/argv ]] || fail "unexpected mise call"; }
expect_calls() {
  printf '%s\0' "$@" >"$test_tmp/expected"
  # Each expected argument list is separated by a newline in the actual log.
  /usr/bin/tr -d '\n' <"$test_tmp/argv" >"$test_tmp/actual"
  /usr/bin/cmp "$test_tmp/expected" "$test_tmp/actual" || fail "exact mise argv"
}

reset_case
reject --check
no_mise
[[ ! -s $test_tmp/probes ]] || fail "absent means no command probe"
for arg in "" --invalid; do reject "$arg"; done
reject --now extra
reject --check extra
no_mise
pass "absence and invalid/empty/excess arguments do not install"

for tool in axon bun; do
  reset_case
  runtime "$tool"
  : >"$test_tmp/broken-$tool"
  reject --check
  reject --now
  no_mise
  pass "broken foreign $tool is not shadowed"

  reset_case
  # Generate the actual known wrapper, but only inside the disposable HOME.
  /bin/bash "$ROOT/bin/omarchy-mise-install" "$tool" "$tool"
  /bin/mv "$HOME/.local/bin/$tool" "$test_tmp/bin/$tool"
  reject --check
  reject --now
  no_mise
  [[ ! -s $test_tmp/probes ]] || fail "cold wrapper executed"
  pass "cold $tool wrapper never executes"
done

reset_case
runtime axon
"$installer" --check
"$installer" --now
"$installer"
no_mise
pass "working Axon (including shim probes with auto-install disabled) is preserved"

reset_case
runtime bun
"$installer" --now
expect_calls use -g --fuzzy npm:@arcforge/axon@latest
pass "working Bun is reused without changing Node or Bun"

reset_case
"$installer" --now
expect_calls ls --global --json use -g --fuzzy bun@latest use -g --fuzzy npm:@arcforge/axon@latest
pass "genuinely absent runtimes add only fuzzy Bun and Axon"

for installed in true false; do
  reset_case
  export AXON_SELECTIONS='{"bun":[{"version":"1.4.0","requested_version":"1.4","installed":'"$installed"',"source":{"path":"config.toml"}}]}'
  reject --now
  expect_calls ls --global --json
  pass "configured Bun is preserved, installed=$installed"
done

reset_case
export AXON_SELECTIONS='{"bun":[{"version":"1.4.0","source":null}]}'
"$installer" --now
expect_calls ls --global --json use -g --fuzzy bun@latest use -g --fuzzy npm:@arcforge/axon@latest
pass "unselected cached Bun is not mistaken for a configured selection"

reset_case
export AXON_SELECTIONS='[]'
reject --now
expect_calls ls --global --json
pass "unexpected selection format fails closed"

reset_case
runtime bun
: >"$test_tmp/install-fail"
reject --now
expect_calls use -g --fuzzy npm:@arcforge/axon@latest
pass "install failure propagates"

reset_case
runtime bun
: >"$test_tmp/broken-axon"
reject --now
expect_calls use -g --fuzzy npm:@arcforge/axon@latest
pass "runtime incompatibility fails without overwriting Bun"

# Mise shims are compiled executables, not shell wrappers. They must never
# be scanned for wrapper text: arbitrary bytes in an ELF file can match it.
reset_case
cp /usr/bin/true "$test_tmp/bin/axon"
printf 'mise use -g\n' >>"$test_tmp/bin/axon"
"$installer" --check
no_mise
pass "a compiled mise shim is probed rather than mistaken for a cold wrapper"

# Model a mise shim separately from a foreign executable: dispatch to an
# installed target, and record any attempt to auto-install a missing target.
reset_case
shim_dir="$HOME/.local/share/mise/shims"
cat >"$shim_dir/axon" <<'SH'
#!/bin/bash
if [[ ${MISE_AUTO_INSTALL:-} != 0 || ${MISE_EXEC_AUTO_INSTALL:-} != 0 || ${MISE_NOT_FOUND_AUTO_INSTALL:-} != 0 ]]; then
  : >"$AXON_TEST/implicit-install"
  exit 8
fi
[[ -f "$AXON_TEST/installed-axon" ]] || exit 1
exec "$AXON_TEST/installed-axon" "$@"
SH
chmod +x "$shim_dir/axon"
export PATH="$shim_dir:$PATH"
touch "$test_tmp/shim-mode"
cp "$test_tmp/runtime" "$test_tmp/installed-axon"
"$installer" --check
"$installer" --now
no_mise
/bin/rm "$test_tmp/installed-axon"
reject --check
export AXON_SELECTIONS='{}'
"$installer" --now
expect_calls ls --global --json use -g --fuzzy bun@latest use -g --fuzzy npm:@arcforge/axon@latest
[[ ! -e $test_tmp/implicit-install ]] || fail "shim tried implicit installation"
pass "installed and missing mise shim targets probe without implicit installs"
