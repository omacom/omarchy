#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

migration="$ROOT/migrations/1792363203.sh"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

export TEST_TMP=$test_tmp
export FAKE_ROOT=$test_tmp/root
zen_dist=$FAKE_ROOT/opt/zen-browser-bin/distribution
zen_etc=$FAKE_ROOT/etc/zen/policies
mock_bin=$test_tmp/bin
mkdir -p "$mock_bin" "$test_tmp/home" "$test_tmp/tmp"

# sudo runs a command only when every path it names is in the scratch tree,
# without the root ownership flags. Anything else is recorded, never run.
cat >"$mock_bin/sudo" <<'SH'
#!/bin/bash
args=()
skip=0
for arg in "$@"; do
  if (( skip )); then
    skip=0
    continue
  fi
  case $arg in
  -o | -g) skip=1; continue ;;
  /*)
    if [[ $arg != "$TEST_TMP"/* ]]; then
      printf '%s\n' "$*" >>"$TEST_TMP/outside"
      exit 0
    fi
    ;;
  esac
  args+=("$arg")
done
"${args[@]}"
SH

# Scratch files stand in for root-owned ones.
cat >"$mock_bin/stat" <<'SH'
#!/bin/bash
if [[ $1 == "-c" && $2 == "%U" && $3 == "$TEST_TMP"/* ]]; then
  echo root
else
  exec /usr/bin/stat "$@"
fi
SH

printf '#!/bin/bash\nexit 0\n' >"$mock_bin/omarchy-pkg-aur-add"
# Removal: the package goes away, and Zen is not the default browser.
printf '#!/bin/bash\nrm -rf "$FAKE_ROOT/opt/zen-browser-bin"\n' >"$mock_bin/omarchy-pkg-drop"
printf '#!/bin/bash\n[[ ! -e $FAKE_ROOT/opt/zen-browser-bin ]]\n' >"$mock_bin/omarchy-pkg-missing"
printf '#!/bin/bash\necho chromium.desktop\n' >"$mock_bin/omarchy-cmd-default-browser"
printf '#!/bin/bash\nexit 0\n' >"$mock_bin/omarchy-lifecycle-dispatch"
chmod +x "$mock_bin"/*

# The real helper with Zen's two paths moved under FAKE_ROOT. as_root skips sudo
# as root, so route it through the stub or the installer writes the host's /opt.
omarchy_path=$test_tmp/omarchy
mkdir -p "$omarchy_path/install/helpers"
ln -s "$ROOT/default" "$omarchy_path/default"
cat >"$omarchy_path/install/helpers/browser-policy.sh" <<'SH'
source "$ROOT/install/helpers/browser-policy.sh"
BROWSER_POLICY_ZEN_DIR=$FAKE_ROOT$BROWSER_POLICY_ZEN_DIR
BROWSER_POLICY_ZEN_PACKAGED=$FAKE_ROOT$BROWSER_POLICY_ZEN_PACKAGED
as_root() { sudo "$@"; }
SH

package_policies='{"policies": {"DisableAppUpdate": true, "DefaultSerialGuardSetting": 3}}'
expected='{"DisableAppUpdate":true,"DefaultSerialGuardSetting":3,"DontCheckDefaultBrowser":true}'

# What zen-browser-bin writes on every install and upgrade.
install_package() {
  install -d -m 0755 "$zen_dist"
  printf '%s\n' "$package_policies" >"$zen_dist/policies.json"
  chmod 0644 "$zen_dist/policies.json"
}

# The file Zen reads: /etc/zen/policies/policies.json when it exists, else
# the one in its distribution directory.
zen_policies() {
  local file=$zen_etc/policies.json
  [[ -e $file ]] || file=$zen_dist/policies.json
  jq -c '.policies' "$file"
}

run_installer() {
  HOME="$test_tmp/home" OMARCHY_PATH="$omarchy_path" PATH="$mock_bin:$PATH" TMPDIR="$test_tmp/tmp" \
    "$ROOT/bin/omarchy-install-browser" zen >/dev/null || fail "the Zen installer finishes"
}

run_remover() {
  HOME="$test_tmp/home" OMARCHY_PATH="$omarchy_path" PATH="$mock_bin:$PATH" TMPDIR="$test_tmp/tmp" \
    "$ROOT/bin/omarchy-remove-browser" zen >/dev/null || fail "the Zen remover finishes"
}

run_migration() {
  HOME="$test_tmp/home" OMARCHY_PATH="$omarchy_path" PATH="$mock_bin:$PATH" TMPDIR="$test_tmp/tmp" \
    bash -euo pipefail "$migration" >/dev/null || fail "the Zen migration runs"
}

defaults=$(bash -c 'source "$1"; printf "%s %s" "$BROWSER_POLICY_ZEN_DIR" "$BROWSER_POLICY_ZEN_PACKAGED"' _ "$ROOT/install/helpers/browser-policy.sh")
[[ $defaults == "/etc/zen/policies /opt/zen-browser-bin/distribution/policies.json" ]] ||
  fail "the helper keeps Zen's setting in /etc/zen/policies, seeded from zen-browser-bin's policies" "$defaults"
pass "the helper keeps Zen's setting in /etc/zen/policies, seeded from zen-browser-bin's policies"

[[ -f $migration ]] || fail "a migration adds Zen's default browser setting"
rm -rf "$FAKE_ROOT"
run_migration
[[ ! -e $FAKE_ROOT/etc/zen ]] || fail "the migration writes nothing without zen-browser-bin"
pass "the migration writes nothing without zen-browser-bin"

install_package
run_migration
run_migration
[[ $(zen_policies) == "$expected" ]] ||
  fail "the migration adds DontCheckDefaultBrowser to Zen's policies and keeps the package's" "$(zen_policies)"
install_package
[[ $(zen_policies) == "$expected" ]] ||
  fail "Zen keeps DontCheckDefaultBrowser after zen-browser-bin rewrites its policies.json" "$(zen_policies)"
mode=$(stat -c '%a' "$zen_etc/policies.json")
[[ $mode == "644" ]] || fail "Zen's system policies are 0644" "mode=$mode"
pass "the migration stops Zen's default browser prompt, and it survives a package update"

rm -rf "$FAKE_ROOT"
install_package
run_installer
[[ $(zen_policies) == "$expected" ]] ||
  fail "the installer adds DontCheckDefaultBrowser to Zen's policies and keeps the package's" "$(zen_policies)"
install_package
[[ $(zen_policies) == "$expected" ]] ||
  fail "Zen keeps DontCheckDefaultBrowser after zen-browser-bin rewrites its policies.json" "$(zen_policies)"
pass "the installer stops Zen's default browser prompt, and it survives a package update"

run_remover
[[ ! -e $FAKE_ROOT/etc/zen ]] || fail "removing Zen deletes the /etc/zen Omarchy wrote" "$(find "$FAKE_ROOT/etc/zen")"
pass "removing Zen deletes the /etc/zen Omarchy wrote"

rm -rf "$FAKE_ROOT"
install_package
install -d -m 0755 "$zen_etc"
printf '{"policies": {"DisableTelemetry": true}}\n' >"$zen_etc/policies.json"
run_installer
[[ $(zen_policies) == '{"DisableTelemetry":true,"DontCheckDefaultBrowser":true}' ]] ||
  fail "an administrator's /etc/zen policies are kept and get the setting beside them" "$(zen_policies)"
run_remover
[[ $(jq -c '.policies' "$zen_etc/policies.json") == '{"DisableTelemetry":true,"DontCheckDefaultBrowser":true}' ]] ||
  fail "removing Zen keeps an administrator's /etc/zen policies"
pass "an administrator's /etc/zen policies are kept, through install and removal"

if [[ -e $test_tmp/outside ]] && grep -E '/etc|zen-browser-bin' "$test_tmp/outside" >/dev/null; then
  fail "Zen's policies are written only inside the scratch tree" "$(cat "$test_tmp/outside")"
fi
pass "Zen's policies are written only inside the scratch tree"
