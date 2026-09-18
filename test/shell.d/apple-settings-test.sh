#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir "$work/bin"
cat >"$work/bin/omarchy-hw-apple-silicon" <<'STUB'
#!/bin/bash
[[ ${APPLE:-0} == 1 ]]
STUB
cat >"$work/bin/omarchy-update-pacman" <<'STUB'
#!/bin/bash
echo "update-pacman $*" >>"$CALLS"
exit "${PKG_STATUS:-0}"
STUB
cat >"$work/bin/pacman" <<'STUB'
#!/bin/bash
echo "$*" >>"$CALLS"
exit "${PKG_STATUS:-0}"
STUB
cat >"$work/bin/systemctl" <<'STUB'
#!/bin/bash
[[ $1 != is-active ]]
STUB
chmod +x "$work/bin/"*
export CALLS="$work/calls" PATH="$work/bin:$ROOT/bin:$PATH"
# Redirect legacy networkd cleanup to a temporary root as well.
sed "s|/etc/systemd/network/|$work/network/|g" "$ROOT/install/hardware/network.sh" >"$work/network.sh"
for apple in 0 1; do
  APPLE=$apple bash -eE -c 'source "$1"' bash "$work/network.sh"
  APPLE=$apple bash -euo pipefail "$ROOT/migrations/1789275235.sh"
done
[[ $(grep -c -- '^-Q omarchy-settings-asahi$' "$CALLS") == 1 ]] || fail 'only Apple setup requires the add-on'
[[ $(grep -c -- '^update-pacman -S --needed --noconfirm omarchy-settings-asahi$' "$CALLS") == 1 ]] || fail 'only Apple migration installs the add-on through the protected transaction wrapper'
status=0
APPLE=1 PKG_STATUS=42 bash -euo pipefail "$ROOT/migrations/1789275235.sh" || status=$?
[[ $status == 42 ]] || fail 'failed package installation leaves migration pending'
status=0
APPLE=1 PKG_STATUS=1 bash -eE -c 'source "$1"' bash "$work/network.sh" 2>"$work/missing.err" || status=$?
[[ $status == 1 ]] || fail 'fresh setup cannot silently omit the Apple default'
grep -q 'Apple setup requires omarchy-settings-asahi' "$work/missing.err" || fail 'fresh setup explains the missing package'
APPLE=0 PKG_STATUS=1 bash -eE -c 'source "$1"' bash "$work/network.sh"
pass 'Apple-only setup and migration require the packaged default and propagate failures'
