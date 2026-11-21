#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# omarchy-boot-backend names the loader whose boot images Omarchy keeps: the
# switch's phase once there is one, omarchy-boot-systemd on a machine installed
# with systemd-boot, and Limine's entry tool otherwise.

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin" "$tmp/sys" "$tmp/store"
# Only the tools the script uses, so this machine's own boot loader stays out.
for tool in bash sed tail; do
  ln -s "$(command -v "$tool")" "$tmp/sys/$tool"
done
ln -s "$ROOT/bin/omarchy-cmd-present" "$tmp/sys/omarchy-cmd-present"

backend() {
  env PATH="$tmp/bin:$tmp/sys" OMARCHY_BOOT_STORE="$tmp/store" \
    OMARCHY_BOOT_SYSTEMD_MARKER="$tmp/marker" "$ROOT/bin/omarchy-boot-backend" "$@" | paste -sd' ' -
}

[[ $(backend) == none ]] || fail "a machine with no boot tooling has none" "$(backend)"

printf '#!/bin/bash\n' >"$tmp/bin/limine-entry-tool"
chmod +x "$tmp/bin/limine-entry-tool"
[[ $(backend) == limine ]] || fail "a Limine machine has limine" "$(backend)"
pass "a machine with Limine's entry tool and no switch boots Limine"

echo 'phase=trial' >"$tmp/store/state"
[[ $(backend) == limine && $(backend --managed) == "limine systemd-boot" ]] ||
  fail "a switch on trial keeps both loaders current" "$(backend) / $(backend --managed)"
echo 'phase=promoted' >"$tmp/store/state"
[[ $(backend) == systemd-boot && $(backend --managed) == "limine systemd-boot" ]] ||
  fail "a promoted switch boots systemd-boot and keeps Limine, its fallback, current" "$(backend) / $(backend --managed)"
echo 'phase=active' >"$tmp/store/state"
[[ $(backend) == systemd-boot && $(backend --managed) == systemd-boot ]] || fail "a finished switch boots systemd-boot"
pass "the switch's phase decides while there is one"

rm "$tmp/store/state" "$tmp/bin/limine-entry-tool"
touch "$tmp/marker"
[[ $(backend) == systemd-boot ]] || fail "a machine installed with systemd-boot boots it, store or not" "$(backend)"
pass "omarchy-boot-systemd marks a machine installed with systemd-boot"
