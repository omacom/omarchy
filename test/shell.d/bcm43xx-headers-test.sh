#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

fix="$ROOT/install/hardware/fix-bcm43xx.sh"
migration="$ROOT/migrations/1789532833.sh"

rg -q 'omarchy-pkg-add "\$kernel-headers"' "$fix" ||
  fail "Broadcom installer installs matching kernel headers before DKMS"
rg -q 'omarchy-pkg-add broadcom-wl-dkms' "$fix" ||
  fail "Broadcom installer still installs the DKMS driver"
pass "Broadcom installer builds DKMS against matching headers"

rg -q 'omarchy-pkg-present broadcom-wl-dkms' "$migration" ||
  fail "Broadcom header repair only runs when the DKMS driver is installed"
rg -q 'linux linux-lts linux-omarchy linux-t2' "$migration" ||
  fail "Broadcom header repair covers stock linux as well as Omarchy/T2 kernels"
pass "Broadcom DKMS header migration covers stock linux"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir/bin"
export INSTALLED_PACKAGES="$tmp_dir/installed" CALL_LOG="$tmp_dir/calls"
export PATH="$tmp_dir/bin:$ROOT/bin:$PATH"

cat > "$tmp_dir/bin/pacman" <<'SH'
#!/bin/bash
case "$1" in
  -Q) grep -Fxq -- "$2" "$INSTALLED_PACKAGES" ;;
  -S)
    shift 3
    printf '%s\n' "$@" >> "$INSTALLED_PACKAGES"
    printf '%s\n' "$@" >> "$CALL_LOG"
    ;;
  *) exit 1 ;;
esac
SH
cat > "$tmp_dir/bin/sudo" <<'SH'
#!/bin/bash
[[ $1 == "pacman" ]] || exit 1
"$@"
SH
chmod +x "$tmp_dir/bin/"*

printf '%s\n' linux broadcom-wl-dkms > "$INSTALLED_PACKAGES"
: > "$CALL_LOG"
bash -euo pipefail "$migration" >/dev/null
grep -Fxq linux-headers "$INSTALLED_PACKAGES" || fail "linux gets headers when broadcom-wl-dkms is present"
: > "$CALL_LOG"
bash -euo pipefail "$migration" >/dev/null
[[ ! -s $CALL_LOG ]] || fail "Broadcom header repair is idempotent"
pass "missing linux-headers are repaired for broadcom-wl-dkms"

printf '%s\n' linux > "$INSTALLED_PACKAGES"
: > "$CALL_LOG"
bash -euo pipefail "$migration" >/dev/null
[[ ! -s $CALL_LOG ]] || fail "header repair skips machines without broadcom-wl-dkms"
pass "Broadcom header repair is a no-op without the DKMS driver"
