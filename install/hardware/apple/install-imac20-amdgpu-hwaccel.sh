# 2020 27" 5K iMac (iMac20,1 / iMac20,2) with AMD Navi 14 — HW accel opt-in.
#
# Companion to fix-imac20-display.sh. That script gets the user to a working
# desktop by holding the EFI simple-framebuffer (Plymouth-suppression +
# nomodeset). This script is the next step: it adds an opt-in path that
# builds and installs a patched amdgpu.ko (with the t2linux 6001 SMU fix
# compiled in) and stages a Limine 'imac20-hwaccel' boot entry alongside
# the existing safe entry.
#
# It is run AFTER the base safe-fallback is in place, because the safe
# fallback is what makes the system robust enough to even consider turning
# the patched module on. See:
#   https://github.com/omacom/omarchy/issues/12197
#   https://github.com/McoreD/imac20-amdgpu-patch  (companion repo)

set -euo pipefail

# Only proceed on the exact hardware signature this targets.
if ! omarchy-hw-imac20-navi14; then
  echo "Not a 2020 5K iMac with Navi 14; skipping HW-accel opt-in"
  exit 0
fi

PATCH_REPO="https://github.com/McoreD/imac20-amdgpu-patch.git"
INSTALL_ROOT="/opt/imac20-amdgpu-patch"
KREL=$(uname -r)
LIVE_MODULE="/lib/modules/$KREL/kernel/drivers/gpu/drm/amd/amdgpu/amdgpu.ko.zst"
STOCK_BACKUP="/usr/lib/amdgpu-stock-backup/amdgpu.ko.zst"

echo "iMac20,1/iMac20,2 + Navi 14 detected; enabling HW acceleration opt-in"

# Sanity: running kernel is one safe-fallback has been applied for. (If a
# future user runs this on a machine that never went through the safe
# fallback path, amdgpu probably still won't bind. Refuse rather than fail
# in confusing ways.)
if ! grep -q 'nomodeset' /proc/cmdline; then
  echo "This machine is not currently running with the iMac20 safe-fallback cmdline."
  echo "Reboot into the safe entry first, then re-run this script."
  exit 1
fi

# Build prerequisites the user might not have if they skipped a full
# base-devel install.
if ! command -v bc >/dev/null 2>&1; then
  echo "Missing 'bc'; install with: sudo pacman -S --needed bc"
  exit 1
fi

# 1. Clone the companion repo (shallow, fast) into a stable location.
if [[ ! -d $INSTALL_ROOT ]]; then
  echo "Cloning companion repo to $INSTALL_ROOT"
  git clone --depth 1 "$PATCH_REPO" "$INSTALL_ROOT"
else
  echo "Companion repo already at $INSTALL_ROOT; updating"
  git -C "$INSTALL_ROOT" pull --ff-only
fi

# 2. Build the patched module + install + UKI variant + pacman hook + Limine
#    hwaccel entry. Each script is idempotent.
echo "Building patched amdgpu.ko + staging HW-accel boot entry..."
"$INSTALL_ROOT/scripts/build-amdgpu-install.sh"
"$INSTALL_ROOT/scripts/install-pacman-hook.sh"
"$INSTALL_ROOT/scripts/install-limine-hwaccel-entry.sh"

# 3. If the upstream linux-t2 package does not include the t2linux 6001
#    patch (the gap this PR exists to work around), the rebuilt module is
#    our only safety net. Reflect that explicitly in the live module's
#    signature so journal audits can verify.
echo "Verifying patched module is in place..."
if ! zstdcat "$LIVE_MODULE" 2>/dev/null | python3 -c "
import sys
d = sys.stdin.buffer.read()
sys.exit(0 if d.count(bytes.fromhex('bbafc9ab')) >= 1 else 1)
"; then
  echo "FAIL: patched module at $LIVE_MODULE is missing the SMU feature mask"
  echo "      (constant 0xABC9AFBB). Refusing to mark HW accel ready."
  exit 1
fi

# 4. Sanity-preserve the rollback path: warn if the stock backup is missing
#    or unusable (the rollback command in the README needs it).
if [[ ! -f $STOCK_BACKUP ]] || zstdcat "$STOCK_BACKUP" 2>/dev/null | python3 -c "
import sys
sys.exit(0 if sys.stdin.buffer.read().count(bytes.fromhex('bbafc9ab')) == 0 else 1)
"; then
  echo "WARNING: stock module backup at $STOCK_BACKUP is missing or patched."
  echo "         Rollback command in the companion repo README will not restore"
  echo "         the safe module. Re-extract from the installed package with:"
  echo "           pacman -S --noconfirm linux-t2"
fi

cat <<EOF

HW-accel path is staged.
  Patched amdgpu.ko  : $LIVE_MODULE
  Limine entry       : imac20-hwaccel (top-level)
  Pacman re-patch on : every 'pacman -Syu linux-t2'
  Companion docs     : $INSTALL_ROOT/README.md

Default boot entry is still the safe 'nomodeset' one. To try HW accel:

  1. Reboot.
  2. At the Limine menu, pick 'imac20-hwaccel' (8-second window).
  3. If the panel blacks out, hold power 5s and pick the safe entry.

After two successful boots into imac20-hwaccel, promote it to default:

  sudo sed -i 's/KERNEL_CMDLINE\\[default\\]/KERNEL_CMDLINE[imac20-hwaccel]/' \\
          /etc/limine-entry-tool.d/imac20-hwaccel.conf
  sudo limine-mkinitcpio
EOF
