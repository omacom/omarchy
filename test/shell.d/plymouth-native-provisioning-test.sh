#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Both provisioning paths run against a fixture root: the real code with its
# fixed /usr paths moved there, and the native installer stubbed to record the
# module it is handed.
tmp=$(mktemp -d "${TMPDIR:-/var/tmp}/ttfx-test.XXXXXXXX")
root=$tmp/root
omarchy=$tmp/omarchy
calls=$tmp/calls
payload=$root/usr/lib/omarchy/plymouth/ttfx-plymouth.so
module=$root/usr/lib/plymouth/ttfx-plymouth.so
descriptor=$root/usr/share/plymouth/themes/omarchy/omarchy.plymouth

mkdir -p "$omarchy/bin" "$omarchy/install/helpers" "$omarchy/install/config" \
  "$omarchy/install/login" "$omarchy/install/post-install" \
  "${payload%/*}" "${module%/*}" "${descriptor%/*}"
cat >"$omarchy/bin/omarchy-plymouth-ttfx-install" <<SH
#!/bin/bash
printf 'ttfx-install %s\n' "\$*" >>"$calls"
SH
printf '#!/bin/bash\n' >"$omarchy/bin/omarchy-apply-hardware"
chmod +x "$omarchy/bin"/*
printf 'start_install_log() { :; }\nstop_install_log() { :; }\n' >"$omarchy/install/helpers/logging.sh"
: >"$omarchy/install/config/all.sh"
: >"$omarchy/install/login/all.sh"
: >"$omarchy/install/post-install/all.sh"

sed "s|/usr/lib/omarchy/plymouth/|$root/usr/lib/omarchy/plymouth/|g" \
  "$ROOT/bin/omarchy-apply-system" >"$omarchy/bin/omarchy-apply-system"
grep -Fq "ttfx_payload=$payload" "$omarchy/bin/omarchy-apply-system" ||
  fail "target finalization still names the packaged TTFX payload"

reset_fixture() {
  rm -f -- "$payload" "$module" "$descriptor" "$calls" "$tmp/state"
  : >"$calls"
}

apply_system() {
  unshare --user --map-root-user env OMARCHY_PATH="$omarchy" \
    OMARCHY_INSTALL_LOG_FILE="$tmp/install.log" \
    /bin/bash "$omarchy/bin/omarchy-apply-system" --defer-provisioning "$@" >"$tmp/apply.out" 2>&1 ||
    fail "omarchy-apply-system runs in the fixture" "$(<"$tmp/apply.out")"
}

# omarchy-apply-system refuses to run unless it is root; a user namespace gives
# it that without privilege.
if unshare --user --map-root-user true 2>/dev/null; then
  reset_fixture
  printf 'payload\n' >"$payload"
  apply_system --first-install
  [[ $(<"$calls") == "ttfx-install --module $payload" ]] ||
    fail "fresh target finalization activates the native payload" "$(<"$calls")"

  reset_fixture
  printf 'payload\n' >"$payload"
  apply_system --upgrade
  [[ ! -s $calls ]] || fail "an upgrade leaves native activation to the installer" "$(<"$calls")"

  reset_fixture
  apply_system --first-install
  [[ ! -s $calls ]] || fail "finalization without the packaged payload activates nothing" "$(<"$calls")"
  pass "fresh target finalization activates native Plymouth"
else
  skip "user namespaces unavailable; skipping target finalization activation"
fi

# The deferred retry is one block inside run_provisioning; run that block.
{
  echo 'retry_native_activation() {'
  sed -n '/# Normally target finalization activated this/,/^  fi$/p' "$ROOT/bin/omarchy-provision-owner"
  echo '}'
} | sed "s|/usr/|$root/usr/|g" >"$tmp/retry.sh"
[[ $(grep -c "$root/usr/" "$tmp/retry.sh") == 3 ]] ||
  fail "deferred provisioning still retries native activation from the packaged payload" "$(<"$tmp/retry.sh")"

retry() {
  (
    PATH="$omarchy/bin:$PATH"
    STATE_FILE=$tmp/state
    log_step() { :; }
    source "$tmp/retry.sh"
    retry_native_activation
  )
}

active_descriptor() {
  printf '[Plymouth Theme]\nModuleName=ttfx-plymouth\n\n[ttfx]\nEnabled=true\nMode=fixed\nEffect=decrypt\n' >"$descriptor"
}

reset_fixture
printf 'payload\n' >"$payload"
retry
[[ $(<"$calls") == "ttfx-install --module $payload" && $(<"$tmp/state") == boot ]] ||
  fail "deferred owner provisioning retries native activation" "$(<"$calls")"

reset_fixture
printf 'payload\n' >"$payload"
cp -- "$payload" "$module"
active_descriptor
retry
[[ ! -s $calls ]] || fail "deferred retry leaves an already active native renderer alone" "$(<"$calls")"

reset_fixture
printf 'payload\n' >"$payload"
printf 'older payload\n' >"$module"
active_descriptor
retry
[[ $(<"$calls") == "ttfx-install --module $payload" ]] ||
  fail "deferred retry replaces a live module that differs from the packaged payload" "$(<"$calls")"

reset_fixture
printf 'payload\n' >"$payload"
cp -- "$payload" "$module"
printf '[Plymouth Theme]\nModuleName=script\n' >"$descriptor"
retry
[[ $(<"$calls") == "ttfx-install --module $payload" ]] ||
  fail "deferred retry activates the module behind the script descriptor" "$(<"$calls")"

reset_fixture
retry
[[ ! -s $calls ]] || fail "deferred retry without the packaged payload activates nothing" "$(<"$calls")"
pass "deferred provisioning has an idempotent activation retry"

# The runtime package lives in omarchy-pkgs; check it only when a checkout is found.
if find_omarchy_pkgs && [[ -f $OMARCHY_PKGS_ROOT/omarchy/PKGBUILD ]]; then
  pkg_text=$(<"$OMARCHY_PKGS_ROOT/omarchy/PKGBUILD")
  for dependency in binutils file pkgconf mkinitcpio; do
    [[ $pkg_text == *"'$dependency'"* ]] || fail "runtime package lacks native installer dependency: $dependency"
  done
  pass "runtime package declares native installer inspection tools"
else
  skip "no omarchy-pkgs checkout; skipping runtime package dependency check"
fi
